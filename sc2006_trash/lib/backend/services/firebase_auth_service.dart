/* Purpose: 
  1. Fetch user data from login/register 
  2. Retrieve FirebaseAuthService from Firebase
  3. Validate/Invalidate user credentials
*/
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// retains information about current user and state change
ValueNotifier<FirebaseAuthService> firebaseAuthService = ValueNotifier(
  FirebaseAuthService(),
);

class FirebaseAuthService {
  // allow us to sign in/register/reset pw etc.
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // have access to current user at any point
  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges =>
      firebaseAuth.authStateChanges(); //return if user is connected or not

  // sign in function
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // create acc function
  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // sign out function
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  // reset password at the login screen
  Future<void> resetPassword({
    required String email,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      onSuccess();
    } catch (e) {
      onError("Failed to send password reset email. Please try again.");
    }
  }

  // update display name
  Future<void> updateUsername({required String username}) async {
    await currentUser!.updateDisplayName(username);
  }

  // dont think we need this function but ill leave it here
  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.delete();
    await firebaseAuth.signOut();
  }

  // reset password at the profile screen, if users want to update their pw
  Future<void> resetPasswordLoggedIn({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  }
}
