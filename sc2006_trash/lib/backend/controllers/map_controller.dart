/* Purpose: Middle man for anything that needs GoogleMapsAPI
  1. Sends google maps information to MapScreen
  2. Handles location services
*/
import 'dart:async';
import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart' as geo;
import '../../backend/models/recycling_bin.dart';
import '../../backend/controllers/recycling_bin_controller.dart';
import '../../backend/controllers/route_controller.dart';

class MapController {
  final Location locationController = Location();
  Completer<GoogleMapController> mapController = Completer();
  final RecyclingBinController recyclingController = RecyclingBinController();
  final RouteController routingController = RouteController();

  Set<Marker> kmlMarkers = {};
  List<RecyclingBin> kmlBins = [];
  LatLng? currentPosition;
  Set<Polyline> polylines = {};

  // gets the user's current location
  Future<LatLng?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await geo.Geolocator.getCurrentPosition(
      locationSettings: geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
      ),
    );
    return LatLng(position.latitude, position.longitude);
  }

  // helper function to move camera to selected location
  Future<void> cameraToPosition(LatLng pos) async {
    if (!mapController.isCompleted) return; // prevent null crash

    final controller = await mapController.future;
    final newCameraPosition = CameraPosition(target: pos, zoom: 14);
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(newCameraPosition),
    );
  }

  // function for map search bar
  Future<void> searchAndSelectBin({
    required String query,
    required List<Marker> allMarkers,
    required List<RecyclingBin> allBins,
    required Function(LatLng) onLocationFound,
    required Function(RecyclingBin, String) onBinSelected,
    required VoidCallback onNotFound,
  }) async {
    for (var i = 0; i < allBins.length; i++) {
      final bin = allBins[i];
      final id = 'kml_bin_$i';

      final match =
          bin.postalCode.startsWith(query) ||
          "${bin.block} ${bin.street}".toLowerCase().contains(
            query.toLowerCase(),
          );

      if (match) {
        onLocationFound(LatLng(bin.latitude, bin.longitude));
        onBinSelected(bin, id);
        return;
      }
    }

    onNotFound();
  }

  // updates user's location periodically
  Future<void> getLocationUpdates(
    Function(LatLng) onUpdate, {
    required LatLng? lastOrigin,
    required Function(LatLng) updateLastOrigin,
    Function(LatLng)? onSignificantMove,
    double threshold = 30,
  }) async {
    bool serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationController.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted =
        await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        final newLatLng = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
        onUpdate(newLatLng);

        if (onSignificantMove != null && lastOrigin != null) {
          final dist = Geolocator.distanceBetween(
            lastOrigin.latitude,
            lastOrigin.longitude,
            newLatLng.latitude,
            newLatLng.longitude,
          );

          if (dist > threshold) {
            updateLastOrigin(newLatLng);
            onSignificantMove(newLatLng);
          }
        }
      }
    });
  }

  // load all recycling bins retrieved from recyclingController
  Future<Set<Marker>> loadKMLMarkers(
    Function(RecyclingBin, String) onTap,
  ) async {
    final generalBins = await recyclingController.getAllRecyclingBins();
    final ewasteBins = await recyclingController.getAllEwasteBins();

    final combinedBins = [...generalBins, ...ewasteBins];
    kmlBins = combinedBins;

    final generalLength = generalBins.length;

    return combinedBins.asMap().entries.map((entry) {
      final bin = entry.value;
      final index = entry.key;

      final isEwaste = index >= generalLength;
      final markerHue =
          isEwaste ? BitmapDescriptor.hueViolet : BitmapDescriptor.hueGreen;

      final markerId = isEwaste ? 'ewaste_bin_$index' : 'recycling_bin_$index';

      return Marker(
        markerId: MarkerId(markerId),
        position: LatLng(bin.latitude, bin.longitude),
        infoWindow: InfoWindow(
          title: '${bin.block} ${bin.street}',
          snippet: bin.description,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
        onTap: () => onTap(bin, markerId),
      );
    }).toSet();
  }
}
