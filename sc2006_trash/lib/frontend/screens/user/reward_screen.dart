import 'package:flutter/material.dart';
import 'package:flutter_create_test/backend/models/user_session.dart';
import 'package:flutter_create_test/backend/services/firestore_service.dart';
import 'package:flutter_create_test/frontend/components/helper.dart';
import 'package:flutter_create_test/backend/controllers/reward_controller.dart';
import 'package:flutter_create_test/backend/models/reward.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  final TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  int? expandedIndex;
  Reward? selectedReward;
  int points = 0;
  String email = '';

  // reward from firestore
  List<Reward> rewards = [];
  List<String> claimedRewardIds = [];
  bool isLoading = true;
  bool showMyRewards = false;
  final rewardController = RewardController();

  @override
  void initState() {
    super.initState();
    loadUserInfo();
    loadData();
  }

  Future<void> loadData() async {
    final uid = UserSession().uid;
    if (uid == null) return;

    final profile = await FirestoreService().getUserProfile(uid);
    final allRewards = await rewardController.getAllRewards();
    final claimedIds = await rewardController.getClaimedRewardIds(uid);

    setState(() {
      emailController.text = profile?['email'] ?? '';
      rewards = allRewards;
      points = profile?['rewardPoints'] ?? 0;
      claimedRewardIds = claimedIds;
      isLoading = false;
    });
  }

  Future<void> loadUserInfo() async {
    final uid = UserSession().uid; // fetch current session UID
    if (uid != null) {
      final data = await FirestoreService().getUserProfile(uid);
      if (data != null) {
        setState(() {
          emailController.text = data['email'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002C93),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Column(
                  children: [
                    _buildPointsHeader(),
                    const SizedBox(height: 25),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
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
                            selectedReward == null
                                ? _buildRewardList()
                                : _buildRewardDetails(),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildPointsHeader() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          width: 300,
          height: 130,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              const SizedBox(height: 5),
              Text(
                points.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF002C93),
                ),
              ),
              const Text(
                "points",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF002C93),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardList() {
    final List<Reward> displayList =
        showMyRewards
            ? rewards.where((r) => claimedRewardIds.contains(r.id)).toList()
            : rewards;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 18.0, top: 10),
          child: Text(
            'Redeem',
            style: TextStyle(
              color: Color(0xFF002C93),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => setState(() => showMyRewards = false),
              child: Text(
                'Redeem',
                style: TextStyle(
                  color: !showMyRewards ? Color(0xFF002C93) : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => showMyRewards = true),
              child: Text(
                'My Rewards',
                style: TextStyle(
                  color: showMyRewards ? Color(0xFF002C93) : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child:
              displayList.isEmpty
                  ? Center(
                    child: Text(
                      showMyRewards
                          ? 'You have not claimed any rewards yet.'
                          : 'No rewards available.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                  : ListView.builder(
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final reward = displayList[index];
                      final isClaimed = claimedRewardIds.contains(reward.id);

                      return GestureDetector(
                        onTap:
                            showMyRewards
                                ? null
                                : () => setState(() => selectedReward = reward),

                        child: Opacity(
                          opacity:
                              showMyRewards ? 1.0 : (isClaimed ? 0.5 : 1.0),
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            margin: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 16,
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
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: Image.asset(
                                      reward.image,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        reward.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Color(0xFF002C93),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            '${reward.points} points',
                                            style: const TextStyle(
                                              color: Color(0xFF002C93),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildRewardDetails() {
    final reward = selectedReward!;
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF002C93)),
                onPressed: () => setState(() => selectedReward = null),
              ),
              const SizedBox(width: 8),
              const Text(
                "Redeem",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF002C93),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12.0),
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: Image.asset(reward.image, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reward.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFF002C93),
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${reward.points} points',
                            style: const TextStyle(
                              color: Color(0xFF002C93),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              controller: mobileController,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              readOnly: true,
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 280,
            height: 40,
            child: TextButton(
              onPressed: () async {
                final uid = UserSession().uid;
                if (uid == null) return;

                final mobile = mobileController.text.trim();

                // Validate mobile number
                if (mobile.isEmpty || !RegExp(r'^\d{8}$').hasMatch(mobile)) {
                  showDialogBox(
                    context: context,
                    title: "Invalid Mobile Number",
                    content:
                        "Please enter a valid 8-digit Singapore mobile number.",
                    onPressed: () {},
                  );
                  return;
                }

                if (points < reward.points) {
                  // not enough points, show error dialog
                  showDialogBox(
                    context: context,
                    title: "Insufficient Points",
                    content:
                        "You do not have enough points to redeem this reward.",
                    onPressed: () {
                      setState(() {
                        selectedReward = null; // Go back to reward list
                      });
                    },
                  );
                  return;
                }

                try {
                  await rewardController.claimReward(uid, reward);
                  final newPoints = points - reward.points;
                  await FirestoreService().updateUserPoints(uid, newPoints);

                  showDialogBox(
                    context: context,
                    title: "Success!",
                    content:
                        "Rewards successfully claimed and can be found under 'My Rewards'!",
                    onPressed: () {
                      setState(() {
                        claimedRewardIds.add(reward.id);
                        points = newPoints;
                        selectedReward = null;
                      });
                    },
                  );
                } catch (e) {
                  showDialogBox(
                    context: context,
                    title: "Error",
                    content: e.toString(),
                    onPressed: () {},
                  );
                }
              },

              style: TextButton.styleFrom(
                backgroundColor: Color(0xFF002C93),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(21),
                ),
              ),
              child: const Text(
                "Submit!",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
