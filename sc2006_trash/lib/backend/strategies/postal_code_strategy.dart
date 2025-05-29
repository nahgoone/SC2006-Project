// implements update interface for user's postal code
import 'package:flutter_create_test/backend/strategies/update_strategy.dart';
import 'package:flutter_create_test/backend/services/firestore_service.dart';

class PostalCodeStrategy implements UpdateStrategy {
  @override
  Future<void> update(String uid, String value) async {
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      throw Exception("Invalid postal code format.");
    }
    await FirestoreService().updateUserProfile(uid, {'postalCode': value});
  }
}
