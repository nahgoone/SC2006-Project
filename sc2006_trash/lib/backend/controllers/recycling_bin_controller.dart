/* Purpose: Handles data between recyclingScreen and recyclingAPI
  1. Passes information from recyclingScreen to recyclingAPI
    - material type filter etc.
  2. Formats the data returned from recyclingAPI
  3. Sends the formatted data back to recyclingScreen to be displayed
  4. data returned should be standardised and reusable
  5. Handles both the ListView and MapView for recycling bins
*/
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:xml/xml.dart' as xml;
import '../models/recycling_bin.dart';

class RecyclingBinController {
  // function to display bins using distance between user
  Future<List<RecyclingBin>> getBinsWithinDistance({
    required LatLng userLocation,
    required double maxDistanceInMeters,
    List<RecyclingBin>? customBinList,
  }) async {
    final allBins = customBinList ?? await getAllCombinedBins();

    return allBins.where((bin) {
      final distance = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        bin.latitude,
        bin.longitude,
      );
      return distance <= maxDistanceInMeters;
    }).toList();
  }

  // combine all general waste and e-waste bins into 1
  Future<List<RecyclingBin>> getAllCombinedBins() async {
    final generalBins = await getAllRecyclingBins();
    final ewasteBins = await getAllEwasteBins();

    return [...generalBins, ...ewasteBins];
  }

  // get all e-waste bins
  Future<List<RecyclingBin>> getAllEwasteBins() async {
    final rawKml = await rootBundle.loadString(
      'assets/kml/EwasteRecyclingKML.kml',
    );
    final document = xml.XmlDocument.parse(rawKml);

    final placemarks = document.findAllElements('Placemark');
    final Map<String, RecyclingBin> prefixBinMap = {};

    for (var placemark in placemarks) {
      final data = Map<String, String>.fromEntries(
        placemark
            .findAllElements('SimpleData')
            .map(
              (e) => MapEntry(e.getAttribute('name') ?? '', e.innerText.trim()),
            ),
      );

      final coordinatesText =
          placemark
              .findAllElements('coordinates')
              .firstOrNull
              ?.innerText
              .trim();
      if (coordinatesText == null) continue;

      final coords = coordinatesText.split(',');
      final lon = double.tryParse(coords[0]) ?? 0.0;
      final lat = double.tryParse(coords[1]) ?? 0.0;

      final postalCode = data['ADDRESSPOSTALCODE'] ?? '';
      if (postalCode.length < 3) continue;

      final postalPrefix = postalCode.substring(0, 3);
      if (prefixBinMap.containsKey(postalPrefix)) continue;

      prefixBinMap[postalPrefix] = RecyclingBin(
        block: data['ADDRESSBLOCKHOUSENUMBER'] ?? '',
        street: data['ADDRESSSTREETNAME'] ?? '',
        postalCode: postalCode,
        buildingName: data['ADDRESSBUILDINGNAME'] ?? '',
        description: data['DESCRIPTION'] ?? '',
        link: data['HYPERLINK'] ?? '',
        latitude: lat,
        longitude: lon,
      );
    }

    return prefixBinMap.values.toList();
  }

  // get all general waste recycling bins
  Future<List<RecyclingBin>> getAllRecyclingBins() async {
    final rawKml = await rootBundle.loadString(
      'assets/kml/RecyclingBinsKML.kml',
    );
    final document = xml.XmlDocument.parse(rawKml);

    final placemarks = document.findAllElements('Placemark');
    final Map<String, RecyclingBin> prefixBinMap = {};

    for (var placemark in placemarks) {
      final data = Map<String, String>.fromEntries(
        placemark
            .findAllElements('SimpleData')
            .map(
              (e) => MapEntry(e.getAttribute('name') ?? '', e.innerText.trim()),
            ),
      );

      final coordinatesText =
          placemark
              .findAllElements('coordinates')
              .firstOrNull
              ?.innerText
              .trim();
      if (coordinatesText == null) continue;

      final coords = coordinatesText.split(',');
      final lon = double.tryParse(coords[0]) ?? 0.0;
      final lat = double.tryParse(coords[1]) ?? 0.0;

      final postalCode = data['ADDRESSPOSTALCODE'] ?? '';
      if (postalCode.length < 3) continue;

      final postalPrefix = postalCode.substring(0, 3);
      if (prefixBinMap.containsKey(postalPrefix)) continue;

      prefixBinMap[postalPrefix] = RecyclingBin(
        block: data['ADDRESSBLOCKHOUSENUMBER'] ?? '',
        street: data['ADDRESSSTREETNAME'] ?? '',
        postalCode: postalCode,
        buildingName: data['ADDRESSBUILDINGNAME'] ?? '',
        description: data['DESCRIPTION'] ?? '',
        link: data['HYPERLINK'] ?? '',
        latitude: lat,
        longitude: lon,
      );
    }

    return prefixBinMap.values.toList();
  }
}
