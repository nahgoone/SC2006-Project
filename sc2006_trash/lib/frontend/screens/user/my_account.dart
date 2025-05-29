import 'package:flutter/material.dart';
import 'package:flutter_create_test/backend/strategies/password_strategy.dart';
import 'package:flutter_create_test/backend/strategies/postal_code_strategy.dart';
import 'package:flutter_create_test/backend/strategies/user_profile_updater.dart';
import 'package:flutter_create_test/backend/controllers/user_controller.dart';
import 'package:flutter_create_test/backend/models/user_profile.dart';
import 'package:flutter_create_test/frontend/screens/user/edit_field_page.dart';
import 'package:flutter_create_test/backend/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_create_test/backend/models/user_session.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  String name = '';
  String email = '';
  String password = '';
  String postalCode = '';
  String profileImageUrl = '';
  bool _isLoading = true;

  // strategy pattern
  late UserProfile userProfile;

  @override
  void initState() {
    super.initState();

    // strategy pattern
    userProfile = UserProfile(
      email: '',
      name: '',
      postalCode: '',
      password: '',
    );
    userProfile.addListener(() => setState(() {}));

    loadUserProfile();
  }

  // strategy pattern
  @override
  void dispose() {
    userProfile.removeListener(() => setState(() {}));
    super.dispose();
  }

  /* ------------------------ Functions Logic Below --------------------------- */

  // update firestore once data is edited
  Future<void> saveFieldToFirestore(String field, String value) async {
    final uid = UserSession().uid;
    if (uid != null) {
      await FirestoreService().updateUserProfile(uid, {field: value});
    }
  }

  // update Password using verification that password is valid from FirebaseAuth
  Future<void> updatePassword(String newPassword) async {
    try {
      await FirebaseAuth.instance.currentUser!.updatePassword(newPassword);
      await saveFieldToFirestore('password', newPassword);

      if (mounted) {
        setState(() => password = newPassword);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _showErrorDialog(e.message ?? 'Failed to update password');
      }
    }
  }

  // error messagge for email and password
  void _showErrorDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Error"),
            content: Text(message),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ],
          ),
    );
  }

  // strategy method
  Future<void> loadUserProfile() async {
    final uid = UserSession().uid;
    if (uid != null) {
      final data = await FirestoreService().getUserProfile(uid);
      if (data != null) {
        userProfile.email = data['email'];
        userProfile.name = data['name'];
        userProfile.postalCode = data['postalCode'];
        userProfile.password = data['password'];
        userProfile.imagePath = data['imagePath'] ?? '';
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final uid = UserSession().uid;
    if (uid == null) return;

    final controller = UserController();
    final downloadUrl = await controller.uploadProfilePicture(uid);

    if (downloadUrl != null) {
      await FirestoreService().updateUserProfile(uid, {
        'imagePath': downloadUrl,
      });

      if (mounted) {
        // strategy pattern
        userProfile.updateField('imagePath', downloadUrl);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile picture updated successfully!')),
        );
      }
    }
  }

  void navigateToEdit(
    String title,
    String currentValue,
    Function(String) onSave,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditFieldPage(
              title: title,
              initialValue: currentValue,
              onSave: onSave,
            ),
      ),
    );
  }

  /* ------------------------ UI Logic Below --------------------------- */

  Widget buildRow(String label, String value, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Text(value, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F2F2),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Stack(
        children: [
          Container(height: 100, color: const Color(0xFF002C93)),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 60),
                        child: Text(
                          'My Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 30),
                        CircleAvatar(
                          radius: 50,
                          // strategy
                          backgroundImage:
                              userProfile.imagePath.isNotEmpty
                                  ? NetworkImage(userProfile.imagePath)
                                  : const AssetImage('images/pp.jpg')
                                      as ImageProvider,
                        ),
                        const SizedBox(height: 5),
                        TextButton(
                          onPressed: () {
                            _pickImage();
                          },
                          child: const Text(
                            "Edit",
                            style: TextStyle(
                              color: Color(0xFF002C93),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // strategy pattern
                  buildRow("Name", userProfile.name, () {
                    navigateToEdit("Name", userProfile.name, (value) async {
                      await saveFieldToFirestore('name', value);
                      userProfile.updateField('name', value);
                    });
                  }),
                  // strategy pattern
                  buildRow("Email", userProfile.email, null),
                  // strategy
                  buildRow("Password", userProfile.password, () {
                    navigateToEdit("Password", userProfile.password, (
                      value,
                    ) async {
                      final updater = UserProfileUpdater(PasswordStrategy());
                      try {
                        await updater.execute(UserSession().uid!, value);
                        userProfile.updateField('password', value);
                      } catch (e) {
                        _showErrorDialog(e.toString());
                      }
                    });
                  }),
                  // strategy
                  buildRow("Postal Code", userProfile.postalCode, () {
                    navigateToEdit("Postal Code", userProfile.postalCode, (
                      value,
                    ) async {
                      final updater = UserProfileUpdater(PostalCodeStrategy());
                      try {
                        await updater.execute(UserSession().uid!, value);
                        userProfile.updateField('postalCode', value);
                      } catch (e) {
                        _showErrorDialog(e.toString());
                      }
                    });
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
