import 'package:flutter/material.dart';
import 'package:flutter_create_test/frontend/components/helper.dart';
import 'package:flutter_create_test/frontend/screens/auth/loginAndRegister_screen.dart';

class CoverPage extends StatefulWidget {

  @override
  _CoverPageState createState() => _CoverPageState();
}

class _CoverPageState extends State<CoverPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF002C93),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "images/Logo.png",
            width: 290,
            height: 290,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          customTextButton(
            text: "Login",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginAndRegisterPage(signUp: false)),
              );
            },
          ),
          const SizedBox(height: 20),
          customTextButton(
            text: "Register",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginAndRegisterPage(signUp: true)),
              );
            },
          ),
        ],
      ),
    );
  }
}
