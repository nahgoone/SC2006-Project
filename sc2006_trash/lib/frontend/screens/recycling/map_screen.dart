import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_create_test/backend/controllers/route_controller.dart';
import 'package:flutter_create_test/backend/facades/map_facade.dart';
import 'package:flutter_create_test/backend/models/recycling_bin.dart';
import 'package:flutter_create_test/frontend/components/helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_create_test/backend/models/user_session.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import '../../../backend/controllers/map_controller.dart';
import '../../../backend/controllers/favourite_controller.dart';

// enum of possible materials
enum ExerciseFilter {
  paper,
  plastic,
  glass,
  metal,
  batteries,
  lamps,
  appliances,
}

class MapPage extends StatefulWidget {
  final RecyclingBin? selectedBinFromFavorites;
  const MapPage({super.key, this.selectedBinFromFavorites});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // controller instances
  Location locationController = Location();
  final MapController mapController = MapController();
  final TextEditingController searchController = TextEditingController();
  final FavouriteController favouriteController = FavouriteController();
  final RouteController routeController = RouteController();
  late final MapFacade mapFacade;

  // variables
  Set<ExerciseFilter> filters = <ExerciseFilter>{};
  double _currentSliderValue = 0;
  Map<String, dynamic>? routingData; // holds mode, duration, etc.
  List<Map<String, dynamic>>? selectedRouteSteps;
  String? selectedMarkerId;
  List<RecyclingBin> favorites = [];
  String loadingText = "Loading...";

  LatLng? currentP;
  LatLng? lastRoutedOrigin;
  RecyclingBin? selectedBin;
  Set<Marker> kmlMarkers = {};

  // helper items
  int expandedCardIndex = -1;
  bool filterByMaterial = false;
  bool filterByDistance = false;
  bool isFavorited = true;
  bool isLoading = true;
  bool viewFavorite = false;
  bool showFilter = false;
  bool showRoutingOptions = false;
  bool showStepDirections = false;
  bool isApplyingFilter = false;
  bool skipRecenterOnFavoriteToggle = false;
  LatLng? _initialCameraTarget;

  @override
  void initState() {
    super.initState();

    // map facade
    mapFacade = MapFacade(
      mapController: mapController,
      routeController: routeController,
      favouriteController: favouriteController,
    );

    if (widget.selectedBinFromFavorites != null) {
      selectedBin = widget.selectedBinFromFavorites;
      selectedMarkerId = "${selectedBin!.block}_${selectedBin!.street}";
      _initialCameraTarget = LatLng(
        selectedBin!.latitude,
        selectedBin!.longitude,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final controller = await mapController.mapController.future;
        await controller.animateCamera(
          CameraUpdate.newLatLngZoom(_initialCameraTarget!, 16),
        );
        controller.showMarkerInfoWindow(MarkerId(selectedMarkerId!));
      });
    }

    mapController.getLocationUpdates(
      (pos) {
        setState(() {
          currentP = pos;
        });
      },
      lastOrigin: lastRoutedOrigin,
      updateLastOrigin: (newOrigin) {
        setState(() {
          lastRoutedOrigin = newOrigin;
        });
      },
      onSignificantMove: (newPos) async {
        if (selectedBin == null) return;
        final data = await mapFacade.getRoutes(
          newPos,
          LatLng(selectedBin!.latitude, selectedBin!.longitude),
        );
        if (!mounted) return;
        setState(() {
          routingData = data;
          showRoutingOptions = true;
        });
      },
    );

    mapFacade.initKMLMarkers(
      favorites: favorites,
      onMarkerTap: (bin, id) {
        setState(() {
          selectedMarkerId = id;
          selectedBin = bin;
          isFavorited = mapFacade.isFavorited(bin, favorites);
        });
      },
      onMarkersLoaded: (loadedMarkers) {
        setState(() {
          kmlMarkers = loadedMarkers;
        });
      },
    );

    final uid = UserSession().uid;
    if (uid != null) {
      mapFacade.loadFavorites(uid).then((favs) {
        setState(() {
          favorites = favs;
          isLoading = false;
        });
      });
    }
  }

  /* ------------------------------ UI widgets -------------------------------------- */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Main content
          Stack(
            children: [
              loadAllBinsOnMap(),
              buildTopBar(),
              if (selectedMarkerId != null) buildMarkerInfoCard(),
              if (showFilter) buildFilterPanel(),
              if (showRoutingOptions) buildRoutingOptionsCard(),
              if (showStepDirections) buildStepByStepDirections(),

              if (!viewFavorite && selectedMarkerId == null && !showFilter)
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.my_location, color: Color(0xFF002C93)),
                    onPressed: () {
                      if (currentP != null) {
                        mapController.cameraToPosition(
                          currentP!,
                        ); // ✅ Only recenter here
                      }
                    },
                  ),
                ),
            ],
          ),

          // Loading overlay
          if (isApplyingFilter)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      loadingText,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // generate google map with overlay of recycling bins
  Widget loadAllBinsOnMap() {
    if (viewFavorite) return buildFavoritesList();

    if (currentP == null) {
      return const Center(
        child: Text("Loading...", style: TextStyle(fontSize: 20)),
      );
    }

    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        if (mapController.mapController.isCompleted) {
          mapController.mapController = Completer<GoogleMapController>();
        }
        mapController.mapController.complete(controller);
      },

      initialCameraPosition: CameraPosition(
        target: _initialCameraTarget ?? currentP!,
        zoom: 14,
      ),
      markers: {
        Marker(
          markerId: MarkerId("_currentLocation"),
          icon: BitmapDescriptor.defaultMarker,
          position: currentP!,
        ),
        ...kmlMarkers,
      },
      polylines: mapController.polylines,
      zoomGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: true,
      rotateGesturesEnabled: true,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      mapType: MapType.normal,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
        Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
        Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
        Factory<VerticalDragGestureRecognizer>(
          () => VerticalDragGestureRecognizer(),
        ),
        Factory<HorizontalDragGestureRecognizer>(
          () => HorizontalDragGestureRecognizer(),
        ),
      },
    );
  }

  Widget buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 100,
        color: const Color(0xFF002C93),
        padding: const EdgeInsets.only(top: 40, bottom: 10),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 40,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Enter postal code",
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(
                      12,
                      10,
                      12,
                      0,
                    ), // Adjust the top value to lower the text
                    hintStyle: TextStyle(
                      fontSize: 13, // Adjust this value to change the font size
                      color:
                          Colors
                              .grey, // You can also change the hint text color here
                    ),
                  ),
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    mapFacade.searchBin(
                      query: value,
                      allMarkers: kmlMarkers.toList(),
                      allBins: mapController.kmlBins,
                      onLocationFound: (LatLng pos) {
                        mapController.cameraToPosition(pos);
                      },
                      onBinSelected: (bin, id) {
                        setState(() {
                          selectedMarkerId = id;
                          selectedBin = bin;
                          isFavorited = favouriteController.isBinFavorited(
                            bin,
                            favorites,
                          );
                        });
                      },
                      onNotFound: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("No bin found for '$value'")),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: Icon(
                viewFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () async {
                setState(() {
                  viewFavorite = !viewFavorite;
                  selectedMarkerId = null;
                  selectedBin = null;
                  showRoutingOptions = false;
                  showStepDirections = false;
                  routingData = null;
                  selectedRouteSteps = null;
                  mapController.polylines.clear();
                  showFilter = false;
                });

                final location =
                    await mapController.locationController.getLocation();
                setState(() {
                  currentP = LatLng(location.latitude!, location.longitude!);
                });

                if (!viewFavorite && !skipRecenterOnFavoriteToggle) {
                  mapController.cameraToPosition(currentP!);
                }

                skipRecenterOnFavoriteToggle = false; // reset after use
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.filter_list,
                color: Colors.white,
                size: 29,
              ),
              onPressed: () {
                setState(() {
                  showFilter = !showFilter;
                });
              },
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  Widget buildFilterPanel() {
    return Positioned(
      top: 350,
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF002C93),
          borderRadius: BorderRadius.vertical(top: Radius.circular(33)),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          "Filter By",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),

                    // Material toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 18.0),
                          child: Text(
                            "Material",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        Switch(
                          value: filterByMaterial,
                          onChanged:
                              (val) => setState(() {
                                filterByMaterial = val;
                              }),
                          activeColor: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),

                    // Material chips
                    Wrap(
                      spacing: 5.0,
                      children:
                          ExerciseFilter.values.map((exercise) {
                            return FilterChip(
                              label: Text(
                                exercise.name[0].toUpperCase() +
                                    exercise.name.substring(1),
                              ),
                              selected: filters.contains(exercise),
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selected) {
                                    filters.add(exercise);
                                  } else {
                                    filters.remove(exercise);
                                  }
                                });
                              },
                              backgroundColor: const Color(0xFF1D4CBA),
                              selectedColor: Colors.white,
                              labelStyle: TextStyle(
                                fontSize: 12,
                                color:
                                    filters.contains(exercise)
                                        ? const Color(0xFF002C93)
                                        : Colors.white,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(color: Colors.white),
                              ),
                              showCheckmark: false,
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 13),

                    // Distance toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 18.0),
                          child: Text(
                            "Max Walking Distance",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        Switch(
                          value: filterByDistance,
                          onChanged:
                              (val) => setState(() {
                                filterByDistance = val;
                              }),
                          activeColor: Colors.white,
                        ),
                      ],
                    ),

                    // Distance slider
                    Column(
                      children: [
                        Slider(
                          value: _currentSliderValue,
                          min: 0,
                          max: 1000,
                          label: _currentSliderValue.toInt().toString(),
                          activeColor: Colors.white,
                          onChanged: (value) {
                            setState(() {
                              _currentSliderValue = value;
                            });
                          },
                        ),
                        Text(
                          "${_currentSliderValue.toInt()}m",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Static buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: shortCustomTextButton(
                    text: "Apply",
                    onPressed: () async {
                      if (currentP == null) return;

                      if (filterByMaterial && filters.isEmpty) {
                        showErrorDialog(
                          context,
                          'Please select at least one material.',
                        );
                        return;
                      }

                      if (filterByDistance && _currentSliderValue == 0) {
                        showErrorDialog(
                          context,
                          'Please select a valid distance.',
                        );
                        return;
                      }

                      setState(() => isApplyingFilter = true);

                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        List<RecyclingBin> filteredBins = mapController.kmlBins;

                        // Distance filter
                        if (filterByDistance) {
                          filteredBins = await mapController.recyclingController
                              .getBinsWithinDistance(
                                userLocation: currentP!,
                                maxDistanceInMeters: _currentSliderValue,
                                customBinList: filteredBins,
                              );

                          if (filteredBins.isEmpty) {
                            setState(() => isApplyingFilter = false);
                            showErrorDialog(
                              context,
                              'No recycling bins found within the selected distance.',
                            );
                            return;
                          }
                        }

                        // Material filter
                        if (filterByMaterial) {
                          final selectedKeywords =
                              filters.map((f) => f.name.toLowerCase()).toList();

                          filteredBins =
                              filteredBins.where((bin) {
                                final desc = bin.description.toLowerCase();
                                return selectedKeywords.every(
                                  (kw) => desc.contains(kw),
                                );
                              }).toList();

                          if (filteredBins.isEmpty) {
                            setState(() => isApplyingFilter = false);
                            showErrorDialog(
                              context,
                              'No recycling bins match the selected materials.',
                            );
                            return;
                          }
                        }

                        // Build Markers
                        final filteredMarkers =
                            filteredBins.asMap().entries.map((entry) {
                              final bin = entry.value;
                              final index = entry.key;
                              final isEwaste = bin.description
                                  .toLowerCase()
                                  .contains('e-waste');

                              return Marker(
                                markerId: MarkerId('filtered_bin_$index'),
                                position: LatLng(bin.latitude, bin.longitude),
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                  isEwaste
                                      ? BitmapDescriptor.hueViolet
                                      : BitmapDescriptor.hueGreen,
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedMarkerId = 'filtered_bin_$index';
                                    selectedBin = bin;
                                    isFavorited = favouriteController
                                        .isBinFavorited(bin, favorites);
                                  });
                                },
                              );
                            }).toSet();

                        setState(() {
                          kmlMarkers = filteredMarkers;
                          showFilter = false;
                          isApplyingFilter = false;
                        });
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: shortCustomTextButton(
                    text: "Reset",
                    onPressed: () {
                      setState(() => isApplyingFilter = true);

                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        final defaultMarkers = await mapController
                            .loadKMLMarkers((bin, id) {
                              setState(() {
                                selectedMarkerId = id;
                                selectedBin = bin;
                                isFavorited = favouriteController
                                    .isBinFavorited(bin, favorites);
                              });
                            });

                        setState(() {
                          kmlMarkers = defaultMarkers;
                          showFilter = false;
                          isApplyingFilter = false;
                          filterByMaterial = false;
                          filterByDistance = false;
                        });
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFavoritesList() {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : favorites.isEmpty
              ? const Center(child: Text("No favorite bins found."))
              : SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: 90,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final bin = favorites[index];

                        return GestureDetector(
                          onTap: () => toggleCardExpansion(index),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF002C93),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.favorite,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      onPressed:
                                          () => _confirmAndUnfavoriteBin(
                                            context,
                                            bin,
                                          ),
                                    ),

                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        "${bin.block} ${bin.street}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.white
                                            .withOpacity(0.2),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "SG ${bin.postalCode}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          viewFavorite = false;
                                          selectedBin = bin;
                                          selectedMarkerId = 'fav_bin_$index';

                                          _initialCameraTarget = LatLng(
                                            bin.latitude,
                                            bin.longitude,
                                          );
                                        });

                                        // Delay camera move after rebuild
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              mapController.cameraToPosition(
                                                LatLng(
                                                  bin.latitude,
                                                  bin.longitude,
                                                ),
                                              );
                                            });
                                      },
                                    ),

                                    const SizedBox(width: 16),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                if (expandedCardIndex == index) ...[
                                  Container(
                                    height: 230,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF114DD9),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: SingleChildScrollView(
                                              child: _buildFormattedDescription(
                                                bin.description,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          customTextButton(
                                            onPressed: () {
                                              final target = LatLng(
                                                bin.latitude,
                                                bin.longitude,
                                              );

                                              setState(() {
                                                viewFavorite = false;
                                                selectedBin = bin;
                                                selectedMarkerId =
                                                    'fav_bin_$index';
                                                _initialCameraTarget = target;
                                                skipRecenterOnFavoriteToggle =
                                                    true;
                                              });

                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((
                                                    _,
                                                  ) async {
                                                    final controller =
                                                        await mapController
                                                            .mapController
                                                            .future;
                                                    await controller.animateCamera(
                                                      CameraUpdate.newLatLngZoom(
                                                        target,
                                                        16,
                                                      ),
                                                    );
                                                    controller
                                                        .showMarkerInfoWindow(
                                                          MarkerId(
                                                            'fav_bin_$index',
                                                          ),
                                                        );
                                                  });
                                            },
                                            text: "Click here for directions!",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
    );
  }

  Widget buildMarkerInfoCard() {
    if (selectedBin == null) return const SizedBox();

    // calculating distance between bin and user location
    double? distanceMeters;
    if (currentP != null && selectedBin != null) {
      distanceMeters = Geolocator.distanceBetween(
        currentP!.latitude,
        currentP!.longitude,
        selectedBin!.latitude,
        selectedBin!.longitude,
      );
    }

    return Positioned(
      bottom: 20,
      left: 10,
      right: 10,
      top: 360,
      child: Container(
        height: 300,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF002C93),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () async {
                    if (selectedBin == null) return;

                    await mapFacade.toggleFavorite(
                      isCurrentlyFavorited: isFavorited,
                      bin: selectedBin!,
                      onResult: (newState) async {
                        final uid = UserSession().uid;
                        if (uid != null) {
                          final updated = await mapFacade.loadFavorites(uid);
                          setState(() {
                            isFavorited = newState;
                            favorites = updated;
                          });
                        }
                      },
                    );
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 18),
                      Text(
                        "${selectedBin!.block} ${selectedBin!.street}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.visible, // Allow wrapping
                        softWrap: true,
                      ),
                      Text(
                        "SG ${selectedBin!.postalCode}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                miniCustomTextButton(
                  text:
                      distanceMeters != null
                          ? "${(distanceMeters / 1000).toStringAsFixed(2)} km"
                          : "N/A",
                  onPressed: () {},
                ),

                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () {
                    setState(() {
                      selectedMarkerId = null;
                      selectedBin = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 12,
                ),
                child: _buildFormattedDescription(selectedBin!.description),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 17.0,
              ),
              child: customTextButton(
                onPressed: () async {
                  if (selectedBin == null || currentP == null) return;

                  final data = await routeController.getRouteDetailsWithModes(
                    origin: currentP!,
                    destination: LatLng(
                      selectedBin!.latitude,
                      selectedBin!.longitude,
                    ),
                  );

                  setState(() {
                    showRoutingOptions = true;
                    routingData = data;
                  });
                },
                text: "Click here for directions!",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRoutingOptionsCard() {
    if (routingData == null) return const SizedBox();

    final options = routingData!['options'] as List<Map<String, dynamic>>;

    return Positioned(
      bottom: 20,
      left: 10,
      right: 10,
      top: 360,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              "Choose your route",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            // Make route list scrollable
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children:
                    options
                        .map(
                          (route) => ListTile(
                            leading: Icon(_getTransportIcon(route['mode'])),
                            title: Text("Mode: ${route['mode']}"),
                            subtitle: Text("Duration: ${route['duration']}"),
                            trailing: const Icon(Icons.directions),
                            onTap: () async {
                              final steps = route['steps'];
                              if (steps == null || steps.isEmpty) return;

                              await routeController.navigateToRoute(
                                steps: steps,
                                mapController: mapController.mapController,
                                polylines: mapController.polylines,
                              );

                              setState(() {
                                selectedMarkerId = null;
                                selectedBin = null;
                                selectedRouteSteps =
                                    steps; // already includes enriched data
                                showRoutingOptions = false;
                                showStepDirections = true;
                              });
                            },
                          ),
                        )
                        .toList(),
              ),
            ),

            // Back button always at the bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextButton(
                onPressed: () => setState(() => showRoutingOptions = false),
                child: const Text("Back", style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStepByStepDirections() {
    if (selectedRouteSteps == null) return const SizedBox();

    return Positioned(
      left: 10,
      right: 10,
      bottom: 20,
      height: MediaQuery.of(context).size.height * 0.35, // 1/3 of screen height
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
        ),
        child: Column(
          children: [
            const Text(
              "Step-by-Step Directions",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: ListView.separated(
                itemCount: selectedRouteSteps!.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final step = selectedRouteSteps![index];
                  return ListTile(
                    leading: Icon(_getTransportIcon(step['travel_mode'])),
                    title: Text(
                      removeHtmlTags(step['instruction']),
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      "${step['distance']} • ${step['duration']}" +
                          (step['vehicle_type'] != null
                              ? "\nTake ${step['vehicle_type']} ${step['line_name']} from ${step['departure_stop']} to ${step['arrival_stop']}"
                              : ""),
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    showStepDirections = false;
                    showRoutingOptions = true;
                    mapController.polylines.clear();
                  });
                },
                child: const Text("Back", style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ------------------------------ Helper Methods -------------------------------------- */

  String removeHtmlTags(String htmlText) {
    final regex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(regex, '');
  }

  IconData _getTransportIcon(String mode) {
    switch (mode) {
      case 'walking':
        return Icons.directions_walk;
      case 'bicycling':
        return Icons.directions_bike;
      case 'transit':
        return Icons.directions_transit;
      default:
        return Icons.directions;
    }
  }

  Widget _buildFormattedDescription(String raw) {
    final materialLines = <String>[];
    final lowerRaw = raw.toLowerCase();

    // Match by keywords
    if (lowerRaw.contains('paper')) materialLines.add("• Paper");
    if (lowerRaw.contains('plastic')) materialLines.add("• Plastics");
    if (lowerRaw.contains('glass')) materialLines.add("• Glass");
    if (lowerRaw.contains('metal') || lowerRaw.contains('can'))
      materialLines.add("• Metals");
    if (lowerRaw.contains('batteries')) materialLines.add("• Batteries");
    if (lowerRaw.contains('lamp')) materialLines.add("• Lamps");
    if (lowerRaw.contains('ict')) materialLines.add("• ICT equipment");
    if (lowerRaw.contains('appliance')) materialLines.add("• Small appliances");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Description:",
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(raw, style: const TextStyle(color: Colors.white, fontSize: 13)),
        if (materialLines.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            "Accepts recyclables such as:",
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          ...materialLines.map(
            (line) => Text(
              line,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ],
    );
  }

  // for the clickable icon of recycling bin
  void toggleCardExpansion(int index) {
    setState(() {
      expandedCardIndex = expandedCardIndex == index ? -1 : index;
    });
  }

  // for the heart icon when bin card expanded
  bool isBinFavorited(RecyclingBin bin) {
    return favorites.any(
      (fav) => fav.block == bin.block && fav.street == bin.street,
    );
  }

  Future<void> _confirmAndUnfavoriteBin(
    BuildContext context,
    RecyclingBin bin,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Remove from Favorites?"),
          content: const Text("Are you sure you want to unfavorite this bin?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                "Unfavorite",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final uid = UserSession().uid;
      if (uid == null) return;

      await mapFacade.toggleFavorite(
        isCurrentlyFavorited: true,
        bin: bin,
        onResult: (newState) async {
          final updated = await mapFacade.loadFavorites(uid);
          setState(() {
            favorites = updated;
          });
        },
      );
    }
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // dismiss dialog
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
