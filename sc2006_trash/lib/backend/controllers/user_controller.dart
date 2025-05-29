/* Purpose: Management of User's Data
  1. Handles account creation/login functions
  2. Returns user's profile and settings from firestore
*/

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_create_test/backend/models/user_profile.dart';
import 'package:flutter_create_test/backend/services/firebase_auth_service.dart';
import 'package:flutter_create_test/backend/services/firestore_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_create_test/backend/models/user_settings.dart';
import 'package:flutter_create_test/backend/models/user_session.dart';

class UserController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebaseStorage = FirebaseStorage.instance;
  final FirestoreService firestoreService = FirestoreService();

  // updating profile picture method and saving to firebase storage
  Future<String?> uploadProfilePicture(String uid) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    File file = File(image.path);
    String filePath = 'profile_pictures/$uid.jpg';

    try {
      await firebaseStorage.ref(filePath).putFile(file);
      String downloadUrl = await firebaseStorage.ref(filePath).getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  /// get user profile from firestore
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  /// get user settings from firestore
  Future<UserSettings?> getUserSettings() async {
    final uid = UserSession().uid;
    if (uid == null) return null;

    final doc =
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('settings')
            .doc('settings')
            .get();

    if (doc.exists && doc.data() != null) {
      return UserSettings.fromMap(doc.data()!);
    }
    return null;
  }

  /// save user settings to firestore
  Future<void> saveUserSettings(UserSettings settings) async {
    final uid = UserSession().uid;
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('settings')
        .set(settings.toMap());
  }

  // registeration function
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String postalCode,
    required Function(String) onError,
  }) async {
    if (email.isEmpty ||
        password.isEmpty ||
        name.isEmpty ||
        postalCode.isEmpty) {
      onError('All fields are required!');
      return false;
    }

    if (!isValidSingaporePostalCode(postalCode)) {
      onError('Please enter a valid 6-digit Singapore postal code.');
      return false;
    }

    try {
      final userCredential = await firebaseAuthService.value.createAccount(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      final profile = UserProfile(
        email: email,
        name: name,
        postalCode: postalCode,
        password: password,
        rewardPoints: 200,
        imagePath: '',
      );

      await firestoreService.saveUserData(uid: uid, profile: profile);
      return true;
    } on FirebaseAuthException catch (e) {
      onError(e.message ?? 'There was an error.');
      return false;
    } catch (_) {
      onError('An unexpected error occurred.');
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
    required Function(String) onError,
  }) async {
    // Client-side validation
    if (email.isEmpty || password.isEmpty) {
      onError('Please enter your email and password!');
      return false;
    }

    // Check email format
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(email)) {
      onError('Please enter a valid email address.');
      return false;
    }

    // Check password length
    if (password.length < 6) {
      onError('Password must be at least 6 characters.');
      return false;
    }

    // Try Firebase sign-in
    try {
      await firebaseAuthService.value.signIn(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      // More specific error message mapping (optional)
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password provided.';
          break;
        case 'invalid-credential':
          message =
              'Invalid login credentials. Email/Password not found/incorrect';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        default:
          message = e.message ?? 'Authentication failed.';
      }

      onError(message);
      return false;
    } catch (e) {
      onError('An unexpected error occurred.');
      return false;
    }
  }

  // helper function to check valid postal code
  bool isValidSingaporePostalCode(String code) {
    final regex = RegExp(r'^\d{6}$');
    return regex.hasMatch(code);
  }
}
