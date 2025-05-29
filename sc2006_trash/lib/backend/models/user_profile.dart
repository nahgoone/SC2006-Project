/* entity class for user profile
  1. ensures consistent formatting of user profile data
  2. accessed when saving user data into firebase
  3. accessed when retrieving user data from firebase  
*/

import 'package:flutter/material.dart';

// observer pattern on UserProfile (Subject)
class UserProfile extends ChangeNotifier {
  String email;
  String name;
  String postalCode;
  String password;
  int rewardPoints;
  String imagePath;

  UserProfile({
    required this.email,
    required this.name,
    required this.postalCode,
    required this.password,
    this.rewardPoints = 200,
    this.imagePath = '',
  });

  // update/setter method for user attributes
  void updateField(String field, String value) {
    switch (field) {
      case 'name':
        name = value;
        break;
      case 'postalCode':
        postalCode = value;
        break;
      case 'password':
        password = value;
        break;
      case 'imagePath':
        imagePath = value;
        break;
    }
    notifyListeners(); // notify the observers
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'postalCode': postalCode,
      'password': password,
      'rewardPoints': rewardPoints,
      'imagePath': imagePath,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      email: map['email'],
      name: map['name'],
      postalCode: map['postalCode'],
      password: map['password'],
      rewardPoints: map['rewardPoints'] ?? 0,
      imagePath: map['imagePath'] ?? '',
    );
  }
}
