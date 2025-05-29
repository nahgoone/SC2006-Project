import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_create_test/frontend/screens/cover_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // load firebase
  await dotenv.load(fileName: "assets/.env"); // load the .env file
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'TRASH', home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 3), //3 sec
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CoverPage()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF002C93),
      alignment: Alignment.center,
      child: Image.asset(
        "images/Logo.png",
        width: 300,
        height: 300,
        fit: BoxFit.contain,
      ),
    );
  }
}
