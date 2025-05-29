import 'package:flutter/material.dart';
import 'package:flutter_create_test/backend/models/recycling_history.dart';
import 'package:flutter_create_test/backend/models/user_session.dart';
import 'package:flutter_create_test/backend/services/firestore_service.dart';

class RecentActivities extends StatefulWidget {
  const RecentActivities({super.key});

  @override
  State<RecentActivities> createState() => _RecentActivitiesState();
}

class _RecentActivitiesState extends State<RecentActivities> {
  int points = 0;
  String userName = '';
  final FirestoreService _firestoreService = FirestoreService();
  List<RecyclingHistory> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecyclingHistory();
  }

  Future<void> _loadRecyclingHistory() async {
    try {
      final userId = UserSession().uid!;

      // Fetch user profile
      final profile = await _firestoreService.getUserProfile(userId);

      // Fetch history
      final historyList = await _firestoreService.getRecyclingHistory(userId);

      setState(() {
        points = profile?['rewardPoints'] ?? 0;
        userName = profile?['name'] ?? 'Unknown';
        _activities = historyList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002C93),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: Center(
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.fromLTRB(16.0, 1, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF002C93),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          Spacer(),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "10 points = \$1",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        points.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Color(0xFF002C93),
                        ),
                      ),
                      Text(
                        "points",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF002C93),
                        ),
                      ),
                      SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Points Holder",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            userName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            height: 30,
                            child: TextButton(
                              onPressed: (null),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(21),
                                  side: BorderSide(
                                    color: Color(0xFF002C93),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Text(
                                "Redeem",
                                style: const TextStyle(
                                  color: Color(0xFF002C93),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _activities.isEmpty
                        ? const Center(child: Text("No activities yet"))
                        : ListView.builder(
                          itemCount: _activities.length,
                          itemBuilder: (context, index) {
                            final activity = _activities[index];
                            return ActivityTile(
                              title: activity.title,
                              date: '${activity.date} • ${activity.time}',
                              points: activity.rewardsEarned,
                              icon: activity.icon,
                            );
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityTile extends StatelessWidget {
  final String title;
  final String date;
  final int points;
  final IconData icon;

  const ActivityTile({
    Key? key,
    required this.title,
    required this.date,
    required this.points,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Color(0xFF002C93),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                date,
                style: TextStyle(color: Color(0xFF002C93), fontSize: 14),
              ),
            ],
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Text(
              points == -1 ? 'Pending' : '+$points',
              style: TextStyle(
                color: points == -1 ? Colors.orange : Color(0xFF002C93),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Icon(icon, color: Color(0xFF002C93), size: 30),
        ],
      ),
    );
  }
}
