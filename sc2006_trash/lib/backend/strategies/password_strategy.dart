// implements update interface for user's password
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_create_test/backend/strategies/update_strategy.dart';
import 'package:flutter_create_test/backend/services/firestore_service.dart';

class PasswordStrategy implements UpdateStrategy {
  @override
  Future<void> update(String uid, String value) async {
    await FirebaseAuth.instance.currentUser!.updatePassword(value);
    await FirestoreService().updateUserProfile(uid, {'password': value});
  }
}
