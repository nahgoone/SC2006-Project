/* Purpose:
  1. Handles Fetching/Storing of data online on cloud database
  2. Handles API errors and responses
  3. Cloud Database (e.g. firestore)
  4. Database format must be standardised and reusable through all users
  5. Data is stored correctly under the user's unique ID key
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_create_test/backend/models/recycling_bin.dart';
import 'package:flutter_create_test/backend/models/user_profile.dart';
import 'package:flutter_create_test/backend/models/recycling_history.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /* ------------------------ Recycling History Logic Below --------------------------- */
  // add recycling history into user's firestore
  Future<void> addRecyclingHistory(
    String userId,
    RecyclingHistory history,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('recyclingHistory')
        .add(history.toMap());
  }

  // load user's recycling history from firestore
  Future<List<RecyclingHistory>> getRecyclingHistory(String userId) async {
    final snapshot =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('recyclingHistory')
            .orderBy('date', descending: true)
            .get();

    return snapshot.docs
        .map((doc) => RecyclingHistory.fromMap(doc.data()))
        .toList();
  }

  /* ------------------------ Favourite Bins Logic Below --------------------------- */
  // load user's favourite bins from firestore
  Future<List<RecyclingBin>> getFavouriteBins(String uid) async {
    final snapshot =
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('favourite')
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return RecyclingBin(
        block: data["block"]?.toString() ?? "",
        street: data["street"]?.toString() ?? "",
        postalCode: data["postalCode"]?.toString() ?? "",
        buildingName: data["buildingName"]?.toString() ?? "",
        description: data["description"]?.toString() ?? "",
        link: data["link"]?.toString() ?? "",
        latitude: (data["latitude"] ?? 0.0).toDouble(),
        longitude: (data["longitude"] ?? 0.0).toDouble(),
      );
    }).toList();
  }

  // add recycling bin into user's favourite list on firestore
  Future<void> addFavouriteBin(String uid, RecyclingBin bin) async {
    final docId = "${bin.block}_${bin.street}".replaceAll(' ', '_');
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('favourite')
        .doc(docId)
        .set({
          "block": bin.block,
          "street": bin.street,
          "postalCode": bin.postalCode,
          "buildingName": bin.buildingName,
          "description": bin.description,
          "link": bin.link,
          "latitude": bin.latitude,
          "longitude": bin.longitude,
        });
  }

  // remove favourite bin from user's firestore
  Future<void> removeFavouriteBin(String uid, String address) async {
    final docId = address.replaceAll(' ', '_');
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('favourite')
        .doc(docId)
        .delete();
  }

  /* ------------------------ User Logic Below --------------------------- */

  // update user's points after claiming rewards
  Future<void> updateUserPoints(String uid, int newPoints) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('profileData')
        .update({'rewardPoints': newPoints});
  }

  // update user data in firestore
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('profileData')
        .update(data);
  }

  // get the user data info from firebase
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('profile')
            .doc('profileData')
            .get();

    if (doc.exists) {
      return doc.data();
    } else {
      return null;
    }
  }

  /* ------------------------ Registration Logic Below --------------------------- */

  // used when creating new user account
  Future<void> saveUserData({
    required String uid,
    required UserProfile profile,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('profileData')
        .set(profile.toMap());
  }
}
