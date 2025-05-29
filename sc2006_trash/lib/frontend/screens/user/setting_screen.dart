import 'package:flutter/material.dart';
import 'package:flutter_create_test/backend/controllers/user_controller.dart';
import 'package:flutter_create_test/backend/models/user_settings.dart';
import 'package:flutter_create_test/backend/models/user_session.dart';
import 'package:flutter_create_test/frontend/components/helper.dart';
import 'package:flutter_create_test/frontend/screens/cover_page.dart';
import 'package:flutter_create_test/frontend/screens/user/my_account.dart';
import 'package:flutter_create_test/backend/services/firestore_service.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late UserSettings _settings;
  String name = '';
  String email = '';
  String profileImageUrl = '';
  final _controller = UserController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadSettings();
  }

  Future<void> _loadUserInfo() async {
    final uid = UserSession().uid;
    if (uid != null) {
      final data = await FirestoreService().getUserProfile(uid);
      if (data != null) {
        setState(() {
          name = data['name'] ?? '';
          email = data['email'] ?? '';
          profileImageUrl = data['imagePath'] ?? '';
        });
      }
    }
  }

  Future<void> _loadSettings() async {
    final settings = await _controller.getUserSettings();
    setState(() {
      _settings =
          settings ??
          UserSettings(
            gpsLocation: true,
            gpsAutoDetect: true,
            notifications: true,
            maxWalkingDistance: '200m',
          );
      _isLoading = false;
    });
  }

  Future<void> _updateSetting({
    bool? gpsLocation,
    bool? gpsAutoDetect,
    bool? notifications,
    String? maxWalkingDistance,
  }) async {
    final updated = UserSettings(
      gpsLocation: gpsLocation ?? _settings.gpsLocation,
      gpsAutoDetect: gpsAutoDetect ?? _settings.gpsAutoDetect,
      notifications: notifications ?? _settings.notifications,
      maxWalkingDistance: maxWalkingDistance ?? _settings.maxWalkingDistance,
    );
    setState(() {
      _settings = updated;
    });
    await _controller.saveUserSettings(updated);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Stack(
        children: [
          Container(height: 100, color: const Color(0xFF002C93)),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 20),
                  buildSwitchTile(
                    'GPS Location',
                    _settings.gpsLocation,
                    (value) => _updateSetting(gpsLocation: value),
                  ),
                  buildSwitchTile(
                    'GPS Auto-Detect',
                    _settings.gpsAutoDetect,
                    (value) => _updateSetting(gpsAutoDetect: value),
                  ),
                  buildSwitchTile(
                    'Notifications',
                    _settings.notifications,
                    (value) => _updateSetting(notifications: value),
                  ),
                  _buildWalkingDistanceField(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(color: Colors.grey),
                  ),
                  const SizedBox(height: 140),
                  customTextButton(
                    text: "Logout",
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => CoverPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyAccountPage()),
          );
          _loadUserInfo();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage:
                    profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : const AssetImage('images/pp.jpg') as ImageProvider,
              ),

              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(email, style: const TextStyle(fontSize: 14)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSwitchTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF002C93),
          ),
          const Divider(color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildWalkingDistanceField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        title: const Text(
          'Max Walking Distance',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        trailing: SizedBox(
          width: 60,
          height: 37,
          child: TextField(
            controller: TextEditingController(
              text: _settings.maxWalkingDistance,
            ),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.center,
            onSubmitted: (value) {
              _updateSetting(maxWalkingDistance: value);
            },
          ),
        ),
      ),
    );
  }
}
