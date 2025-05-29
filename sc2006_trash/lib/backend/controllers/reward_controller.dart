/* Purpose: Handles user's rewards
  1. Loads all possible rewards user's can claim
  2. Loads all claimed rewards by the user
  3. Handles function related to claiming of rewards by the user
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reward.dart';

class RewardController {
  final _db = FirebaseFirestore.instance;

  // fetch all rewards from firestore
  Future<List<Reward>> getAllRewards() async {
    final snapshot = await _db.collection('rewards').get();
    return snapshot.docs
        .map((doc) => Reward.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  // fetch list of rewards claimed by the user
  Future<List<String>> getClaimedRewardIds(String uid) async {
    final snapshot =
        await _db.collection('users').doc(uid).collection('userRewards').get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // claim reward and save to firestore
  Future<void> claimReward(String uid, Reward reward) async {
    final rewardRef = _db
        .collection('users')
        .doc(uid)
        .collection('userRewards')
        .doc(reward.id);

    final doc = await rewardRef.get();
    if (doc.exists) {
      throw Exception("Reward already claimed");
    }

    await rewardRef.set({'claimed': true});
  }
}
