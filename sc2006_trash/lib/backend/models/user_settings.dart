/* entity class for user settings
  1. ensures consistent formatting of user settings
  2. accessed when saving user settings into firebase
  3. accessed when retrieving user settings from firebase  
*/

class UserSettings {
  final bool gpsLocation;
  final bool gpsAutoDetect;
  final bool notifications;
  final String maxWalkingDistance;

  UserSettings({
    required this.gpsLocation,
    required this.gpsAutoDetect,
    required this.notifications,
    required this.maxWalkingDistance,
  });

  factory UserSettings.fromMap(Map<String, dynamic> data) {
    return UserSettings(
      gpsLocation: data['gpsLocation'] ?? true,
      gpsAutoDetect: data['gpsAutoDetect'] ?? true,
      notifications: data['notifications'] ?? true,
      maxWalkingDistance: data['maxWalkingDistance'] ?? '200m',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gpsLocation': gpsLocation,
      'gpsAutoDetect': gpsAutoDetect,
      'notifications': notifications,
      'maxWalkingDistance': maxWalkingDistance,
    };
  }
}
