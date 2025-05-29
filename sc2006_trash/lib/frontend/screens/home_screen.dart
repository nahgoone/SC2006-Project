import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_create_test/backend/controllers/favourite_controller.dart';
import 'package:flutter_create_test/backend/models/recycling_bin.dart';
import 'package:flutter_create_test/backend/models/user_session.dart';
import 'package:flutter_create_test/backend/services/firestore_service.dart';
import 'package:flutter_create_test/frontend/components/helper.dart';
import 'package:flutter_create_test/frontend/screens/recycling/manuallyInput/manually_input.dart';
import 'package:flutter_create_test/frontend/screens/recycling/map_screen.dart';
import 'package:flutter_create_test/frontend/screens/recycling/scanMaterials/scanner_screen.dart';
import 'package:flutter_create_test/frontend/screens/user/recent_activities.dart';
import 'package:flutter_create_test/frontend/screens/user/reward_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int points = 0;
  int claimedCount = 0;
  final FavouriteController favouriteController = FavouriteController();
  bool viewFavorite = false;
  bool isFavorited = true;
  List<RecyclingBin> favorites = [];
  int expandedCardIndex = -1;
  bool isLoading = true;
  bool showFilter = false;
  String? selectedMarkerId;
  //List<Map<String, String>> favorites = [];
  RecyclingBin? selectedBin;
  String formattedDate = DateFormat('yyyy-MM-dd – EEEE').format(DateTime.now());


  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    final uid = UserSession().uid;
    if (uid != null) {
      final profile = await FirestoreService().getUserProfile(uid);
      final favs = await favouriteController.loadFavoritesFromFirestore(uid);

      // Count claimed rewards
      final claimedSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('userRewards')
              .get();

      setState(() {
        favorites = favs;
        points = profile?['rewardPoints'] ?? 0;
        claimedCount =
            claimedSnapshot.docs.length; // 🔥 Number of claimed rewards
        isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 50, color: Color(0xFF002C93)),
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Color(0xFF002C93), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: SizedBox(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RewardScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(21),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        points.toString(),
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF002C93),
                        ),
                      ),
                      Text(
                        "POINTS",
                        style: TextStyle(color: Color(0xFF002C93)),
                      ),
                      Container(width: 1, height: 40, color: Colors.grey),
                      Text(
                        claimedCount.toString(),
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF002C93),
                        ),
                      ),
                      Text(
                        "REWARDS",
                        style: TextStyle(color: Color(0xFF002C93)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("MY PROGRESS"),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'QUANTITY',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecentActivities(),
                              ),
                            );
                          },
                          child: SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: 10,
                                barTouchData: BarTouchData(enabled: false),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: true),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                barGroups: [
                                  makeGroupData(0, 4, 'Glass'),
                                  makeGroupData(1, 2, 'Aluminium'),
                                  makeGroupData(2, 8, 'Plastic'),
                                  makeGroupData(3, 2, 'Paper'),
                                  makeGroupData(4, 6, 'Metal'),
                                ],
                                gridData: FlGridData(show: false),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF002C93),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Last updated: $formattedDate',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("QUICK LINKS"),
              ),
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 10),
            Row(
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.symmetric(
                      vertical: 3,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: 155,
                      height: 140,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScannerPage(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(21),
                          ),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            const Text(
                              "Scan Material",
                              style: TextStyle(
                                color: Color(0xFF002C93),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Not sure what material you have? Simply scan it, and we'll help you identify them and check whether it's recyclable!",
                              style: TextStyle(
                                color: Color(0xFF002C93),
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Center(
                  child: Container(
                    padding: const EdgeInsets.all(5.0),
                    margin: const EdgeInsets.symmetric(
                      vertical: 3,
                      horizontal: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: 155,
                      height: 140,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ManuallyInput(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(21),
                          ),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            const Text(
                              "Manually Input",
                              style: TextStyle(
                                color: Color(0xFF002C93),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Already know your material? Enter it manually!",
                              style: TextStyle(
                                color: Color(0xFF002C93),
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("FAVOURITES"),
              ),
            ),
            buildFavoritesList(), // Displaying the favorites list here
          ],
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y, String label) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.lightBlueAccent,
          width: 18,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget buildFavoritesList() {
    return Column(
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
                margin: const EdgeInsets.only(bottom: 10),
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
                              () => _confirmAndUnfavoriteBin(context, bin),
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
                        miniCustomTextButton(
                          text: "SG ${bin.postalCode}",
                          onPressed: () {},
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
                        child: Center(
                          child: Column(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: SingleChildScrollView(
                                    child: _buildFormattedDescription(
                                      bin.description,
                                    ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  10,
                                ), // left, top, right, bottom
                                child: customTextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => MapPage(
                                              selectedBinFromFavorites: bin,
                                            ),
                                      ),
                                    );
                                  },
                                  text: "Click here for directions!",
                                ),
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
    );
  }

  Widget buildMarkerInfoCard() {
    if (selectedBin == null) return const SizedBox();

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

                    await favouriteController.toggleFavorite(
                      isCurrentlyFavorited: isFavorited,
                      bin: selectedBin!,
                      onResult: (newState) async {
                        final uid = UserSession().uid;
                        if (uid != null) {
                          final updated = await favouriteController
                              .loadFavoritesFromFirestore(uid);
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
                miniCustomTextButton(text: selectedMarkerId!, onPressed: () {}),
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
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 48, right: 48),
                child:
                    selectedBin!.description.isNotEmpty
                        ? _buildFormattedDescription(selectedBin!.description)
                        : const Text(
                          "No description available.",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 10),
            customTextButton(
              onPressed: () {
                // Optional: open Google Maps or link
                print(
                  "Directions to ${selectedBin!.latitude}, ${selectedBin!.longitude}",
                );
              },
              text: "Click here for directions!",
            ),
          ],
        ),
      ),
    );
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

  /* ------------------------------ Helper Methods -------------------------------------- */
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

      await favouriteController.toggleFavorite(
        isCurrentlyFavorited: true,
        bin: bin,
        onResult: (newState) async {
          final updated = await favouriteController.loadFavoritesFromFirestore(
            uid,
          );
          setState(() {
            favorites = updated;
          });
        },
      );
    }
  }
}
