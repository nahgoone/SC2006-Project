/* Purpose: Handles functions related to routing on map_screen
  1. Passes information from recyclingScreen to recyclingAPI
    - material type filter etc.
  2. Formats the data returned from recyclingAPI
  3. Sends the formatted data back to recyclingScreen to be displayed
  4. data returned should be standardised and reusable
  5. Handles both the ListView and MapView for recycling bins
*/
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RouteController {
  final String googleApiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;

  // get step by step directions, more details about the route to recycling bin
  Future<Map<String, dynamic>> getRouteDetailsWithModes({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final modes = ['walking', 'bicycling', 'transit'];
    final List<Map<String, dynamic>> options = [];

    for (final mode in modes) {
      final url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=$mode&key=$googleApiKey';

      final response = await http.get(Uri.parse(url));
      final json = jsonDecode(response.body);

      if (json['status'] == 'OK') {
        final route = json['routes'][0];
        final leg = route['legs'][0];
        final duration = leg['duration']['text'];
        final polyline = route['overview_polyline']['points'];

        // Extract steps
        final steps =
            (leg['steps'] as List).map<Map<String, dynamic>>((step) {
              final instruction = step['html_instructions'] ?? '';
              final travelMode = step['travel_mode'] ?? '';
              final durationText = step['duration']['text'] ?? '';
              final distanceText = step['distance']['text'] ?? '';
              final encodedPolyline = step['polyline']?['points'];

              String? lineName;
              String? vehicleType;
              String? departureStop;
              String? arrivalStop;

              if (travelMode == 'TRANSIT' && step['transit_details'] != null) {
                final transit = step['transit_details'];
                lineName =
                    transit['line']?['short_name'] ?? transit['line']?['name'];
                vehicleType = transit['line']?['vehicle']?['type'];
                departureStop = transit['departure_stop']?['name'];
                arrivalStop = transit['arrival_stop']?['name'];
              }

              return {
                'instruction': instruction,
                'travel_mode': travelMode,
                'duration': durationText,
                'distance': distanceText,
                'line_name': lineName,
                'vehicle_type': vehicleType,
                'departure_stop': departureStop,
                'arrival_stop': arrivalStop,
                'polyline': encodedPolyline,
              };
            }).toList();

        // determine primary vehicle type (for transit only)
        String? primaryVehicleType;
        if (mode == 'transit') {
          try {
            final firstTransitStep = leg['steps'].firstWhere(
              (s) => s['travel_mode'] == 'TRANSIT',
              orElse: () => null,
            );
            if (firstTransitStep != null &&
                firstTransitStep['transit_details'] != null) {
              primaryVehicleType =
                  firstTransitStep['transit_details']['line']['vehicle']['type'];
            }
          } catch (_) {}
        }

        options.add({
          'mode': mode,
          'duration': duration,
          'polyline': polyline,
          'steps': steps,
          'vehicle_type': primaryVehicleType, // used for coloring
          'rawSteps': leg['steps'],
        });
      }
    }

    return {'options': options};
  }

  Future<List<LatLng>> getRoutePoints(LatLng origin, LatLng destination) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=walking&key=$googleApiKey';

    final response = await http.get(Uri.parse(url));
    final json = jsonDecode(response.body);

    if (json['status'] == 'OK') {
      final points = json['routes'][0]['overview_polyline']['points'];
      return decodePolyline(points);
    } else {
      return [];
    }
  }

  // display polylines from user's location to selected recycling bin
  Future<void> navigateToRoute({
    required List<dynamic> steps,
    required Completer<GoogleMapController> mapController,
    required Set<Polyline> polylines,
  }) async {
    polylines.clear();

    int polylineIdCounter = 1;

    for (var step in steps) {
      if (step['polyline'] == null) continue;

      final encoded = step['polyline'];

      final mode = step['travel_mode'];
      final vehicleType = step['vehicle_type']; // transit-specific

      final color = _getColorForMode(mode, vehicleType); // updated
      final points = decodePolyline(encoded);
      if (points.isEmpty) continue;

      final polyline = Polyline(
        polylineId: PolylineId('step_$polylineIdCounter'),
        color: color,
        width: 6,
        points: points,
      );

      polylines.add(polyline);
      polylineIdCounter++;
    }

    final controller = await mapController.future;
    final allPoints = polylines.expand((p) => p.points).toList();
    if (allPoints.isNotEmpty) {
      final bounds = getBounds(allPoints);
      await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }

  LatLngBounds getBounds(List<LatLng> points) {
    double south = points.first.latitude;
    double north = points.first.latitude;
    double west = points.first.longitude;
    double east = points.first.longitude;

    for (LatLng point in points) {
      if (point.latitude < south) south = point.latitude;
      if (point.latitude > north) north = point.latitude;
      if (point.longitude < west) west = point.longitude;
      if (point.longitude > east) east = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }

  // helper method for coloring polylines based on transport mode
  Color _getColorForMode(String mode, [String? vehicleType]) {
    switch (mode.toLowerCase()) {
      case 'walking':
        return Colors.green;
      case 'bicycling':
        return Colors.orange;
      case 'transit':
        if (vehicleType == 'BUS') return Colors.blue;
        if (vehicleType == 'SUBWAY') return Colors.purple;
        return Colors.grey; // fallback for other transit types
      default:
        return Colors.black;
    }
  }
}
