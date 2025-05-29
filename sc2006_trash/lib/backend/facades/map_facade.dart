/* Purpose: 
  - Provide a unified interface for user map-related processes
  - Acts as a Facade over MapController, RouteController, and FavouriteController
  - Simplifies usage for map screen
*/
import 'dart:async';
import 'package:flutter_create_test/backend/controllers/map_controller.dart';
import 'package:flutter_create_test/backend/controllers/route_controller.dart';
import 'package:flutter_create_test/backend/controllers/favourite_controller.dart';
import 'package:flutter_create_test/backend/models/recycling_bin.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapFacade {
  final MapController mapController;
  final RouteController routeController;
  final FavouriteController favouriteController;

  MapFacade({
    required this.mapController,
    required this.routeController,
    required this.favouriteController,
  });

  Future<void> initKMLMarkers({
    required List<RecyclingBin> favorites,
    required Function(RecyclingBin bin, String markerId) onMarkerTap,
    required Function(Set<Marker> markers) onMarkersLoaded,
  }) async {
    // delegates to MapController
    final markers = await mapController.loadKMLMarkers((bin, id) {
      onMarkerTap(bin, id);
    });
    onMarkersLoaded(markers);
  }

  void searchBin({
    required String query,
    required List<Marker> allMarkers,
    required List<RecyclingBin> allBins,
    required Function(LatLng) onLocationFound,
    required Function(RecyclingBin, String) onBinSelected,
    required Function() onNotFound,
  }) {
    // delegates to MapController
    mapController.searchAndSelectBin(
      query: query,
      allMarkers: allMarkers,
      allBins: allBins,
      onLocationFound: onLocationFound,
      onBinSelected: onBinSelected,
      onNotFound: onNotFound,
    );
  }

  Future<Map<String, dynamic>> getRoutes(LatLng origin, LatLng destination) {
    // delegates to RouteController
    return routeController.getRouteDetailsWithModes(
      origin: origin,
      destination: destination,
    );
  }

  Future<void> handleNavigationRoute(
    List<dynamic> steps,
    Completer<GoogleMapController> mapCtrl,
    Set<Polyline> polylines,
  ) async {
    // delegates to RouteController
    await routeController.navigateToRoute(
      steps: steps,
      mapController: mapCtrl,
      polylines: polylines,
    );
  }

  // delegates to FavouriteController
  Future<List<RecyclingBin>> loadFavorites(String uid) {
    return favouriteController.loadFavoritesFromFirestore(uid);
  }

  // delegates to FavouriteController
  bool isFavorited(RecyclingBin bin, List<RecyclingBin> favorites) {
    return favouriteController.isBinFavorited(bin, favorites);
  }

  // delegates to FavouriteController
  Future<void> toggleFavorite({
    required bool isCurrentlyFavorited,
    required RecyclingBin bin,
    required Function(bool) onResult,
  }) {
    return favouriteController.toggleFavorite(
      isCurrentlyFavorited: isCurrentlyFavorited,
      bin: bin,
      onResult: onResult,
    );
  }
}
