/* entity class for recycling history
  1. ensures consistent formatting of recycling entry
  2. accessed when saving a recycling entry into firebase
  3. accessed when retrieving a recycing entry from firebase  
*/
import 'package:flutter/material.dart';

class RecyclingHistory {
  final String title;
  final String date; // DD/MM/YY
  final String time; // HH/MM
  final int rewardsEarned;
  final String iconName; // store the icon as a string

  RecyclingHistory({
    required this.title,
    required this.date,
    required this.time,
    required this.rewardsEarned,
    required this.iconName,
  });

  IconData get icon => _iconFromName(iconName);

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'time': time,
      'rewardsEarned': rewardsEarned,
      'icon': iconName,
    };
  }

  factory RecyclingHistory.fromMap(Map<String, dynamic> map) {
    return RecyclingHistory(
      title: map['title'],
      date: map['date'],
      time: map['time'],
      rewardsEarned: map['rewardsEarned'] ?? -1,
      iconName: map['icon'],
    );
  }

  // helper function for mapping iconName to icon
  static IconData _iconFromName(String name) {
    switch (name) {
      case 'approval':
        return Icons.approval;
      case 'refresh':
        return Icons.refresh;
      default:
        return Icons.help_outline;
    }
  }
}
