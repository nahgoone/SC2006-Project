// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_create_test/frontend/screens/recycling/manuallyInput/manually_input.dart';
import 'package:flutter_create_test/frontend/screens/recycling/scanMaterials/scanner_screen.dart';

class RecyclingScreen extends StatefulWidget {
  const RecyclingScreen({super.key});

  @override
  State<RecyclingScreen> createState() => _RecyclingScreenState();
}

class _RecyclingScreenState extends State<RecyclingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFF2F2F2),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 2, right: 2, top: 40),
              child: Center(
                child: Text(
                  "Identify Your Recyclables",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Center(
              child: Text(
                "♻️🌱🌎",
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 20),

            Center(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: SizedBox(
                  width: 330,
                  height: 250,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScannerPage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF002C93),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(21),
                      ),
                    ),

                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        const Text(
                          "Scan Material",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Not sure what material you have? Simply scan it, and we'll help you identify them and check whether it's recyclable!",
                          style: TextStyle(color: Colors.white, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: SizedBox(
                              width: 250,
                              height: 250,
                              child: Image.asset(
                                "images/ScanMaterial.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: SizedBox(
                  width: 330,
                  height: 250,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManuallyInput(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF002C93),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(21),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 10),

                        const Text(
                          "Manually Input",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Already know your material? Enter it manually!",
                          style: TextStyle(color: Colors.white, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SizedBox(
                              width: 230,
                              height: 230,
                              child: Image.asset(
                                "images/ManuallyInput.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
