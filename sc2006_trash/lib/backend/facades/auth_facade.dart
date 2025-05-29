/* Purpose: 
  - Provide a unified interface for user authentication-related processes
  - Acts as a Facade over FirebaseAuthService, FirestoreService, and UserController
  - Simplifies usage for login/register screens
*/

import 'package:flutter_create_test/backend/services/firebase_auth_service.dart';
//import 'package:flutter_create_test/backend/services/firestore_service.dart';
import 'package:flutter_create_test/backend/controllers/user_controller.dart';
//import 'package:flutter_create_test/backend/models/user_profile.dart';

class AuthFacade {
  final FirebaseAuthService _authService = FirebaseAuthService();
  //final FirestoreService _firestoreService = FirestoreService();
  final UserController _userController = UserController();

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String postalCode,
    required Function(String) onError,
  }) async {
    // delegates to UserController which includes auth + profile setup logic
    return await _userController.register(
      email: email,
      password: password,
      name: name,
      postalCode: postalCode,
      onError: onError,
    );
  }

  Future<bool> signIn({
    required String email,
    required String password,
    required Function(String) onError,
  }) async {
    // delegates to UserController signIn
    return await _userController.signIn(
      email: email,
      password: password,
      onError: onError,
    );
  }

  Future<void> resetPassword({
    required String email,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    await _authService.resetPassword(
      email: email,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<Map<String, dynamic>?> fetchUserProfile(String uid) async {
    return await _userController.getUserProfile(uid);
  }

  Future<String?> uploadProfileImage(String uid) async {
    return await _userController.uploadProfilePicture(uid);
  }
}
