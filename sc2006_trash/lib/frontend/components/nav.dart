/* Purpose: Navigation
  1. Botton navigation bar for all pages
*/

import 'package:flutter/material.dart';
import 'package:flutter_create_test/frontend/screens/home_screen.dart';
import 'package:flutter_create_test/frontend/screens/recycling/map_screen.dart';
import 'package:flutter_create_test/frontend/screens/recycling/recycling_screen.dart';
import 'package:flutter_create_test/frontend/screens/user/reward_screen.dart';
import 'package:flutter_create_test/frontend/screens/user/setting_screen.dart';

class Nav extends StatefulWidget {
  const Nav({super.key});

  @override
  State<Nav> createState() => _NavState();
}

class _NavState extends State<Nav> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: () async {
          return false; // disables back button
        },
        child: DefaultTabController(
          length: 5,
          child: Scaffold(
            bottomNavigationBar: Container(
              color: const Color(0xFF002C93),
              child: TabBar(
                labelColor: Colors.white,
                labelPadding: EdgeInsets.all(8),
                unselectedLabelColor: const Color.fromARGB(255, 220, 220, 220),
                tabs: [
                  Tab(
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.location_on, size: 23),
                        Text('Location', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                  Tab(
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.recycling, size: 23),
                        Text('Recycle', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                  Tab(
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.home, size: 23),
                        Text('Home', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                  Tab(
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.card_giftcard, size: 23),
                        Text('Rewards', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                  Tab(
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.settings, size: 23),
                        Text('Settings', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              physics:
                  NeverScrollableScrollPhysics(), // disables swipe between tabs
              children: [
                MapPage(),
                RecyclingScreen(),
                HomeScreen(),
                RewardScreen(),
                SettingScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
