/* Purpose: 
  1. Display the login page for user
  2. Allows user input for login credentials
  3. Calls user_controller for authentication
  4. After authentication valid, forward user to home screen
*/
import 'package:flutter/material.dart';
//import 'package:flutter_create_test/backend/controllers/user_controller.dart';
import 'package:flutter_create_test/backend/facades/auth_facade.dart';
import 'package:flutter_create_test/backend/models/user_session.dart';
import 'package:flutter_create_test/frontend/components/helper.dart';
import 'package:flutter_create_test/frontend/components/nav.dart';
import 'package:flutter_create_test/frontend/screens/auth/forgot_password_page.dart';
import 'package:flutter_create_test/backend/services/firebase_auth_service.dart';
import 'package:flutter_create_test/backend/services/firestore_service.dart';

class LoginAndRegisterPage extends StatefulWidget {
  final bool signUp;

  LoginAndRegisterPage({this.signUp = true});

  @override
  _LoginAndRegisterPageState createState() => _LoginAndRegisterPageState();
}

class _LoginAndRegisterPageState extends State<LoginAndRegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  // firestore instance
  final FirestoreService firestoreService = FirestoreService();
  final AuthFacade authFacade = AuthFacade();

  late bool signUp;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    signUp = widget.signUp; // get initial state
  }

  /* ------------------------ Widgets Below --------------------------- */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: const Color(0xFF002C93),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 160),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 43.0),
                  child: Text(
                    signUp ? "Register" : "Login",
                    style: const TextStyle(color: Colors.white, fontSize: 40),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              if (signUp) ...[
                customTextField(
                  controller: nameController,
                  labelText: "Name",
                  icon: Icons.person,
                ),
                const SizedBox(height: 13),

                customTextField(
                  controller: emailController,
                  labelText: "Email",
                  icon: Icons.email,
                ),
                const SizedBox(height: 13),
                customTextField(
                  controller: passwordController,
                  labelText: "Password",
                  icon: Icons.lock,
                ),
                const SizedBox(height: 13),

                customTextField(
                  controller: postalCodeController,
                  labelText: "Postal Code",
                  icon: Icons.location_on,
                ),
                const SizedBox(height: 13),
              ] else ...[
                customTextField(
                  controller: emailController,
                  labelText: "Email",
                  icon: Icons.email,
                ),
                const SizedBox(height: 13),
                customTextField(
                  controller: passwordController,
                  labelText: "Password",
                  icon: Icons.lock,
                ),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(140, 0, 0, 0),
                child:
                    signUp
                        ? SizedBox()
                        : TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Forget Password?",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {},
                child:
                    signUp
                        ? customTextButton(
                          text: "Sign Up",
                          // changed this portion for redirection after signup successful
                          onPressed: () async {
                            bool success = await register();
                            if (success) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          LoginAndRegisterPage(signUp: false),
                                ),
                              );
                            }
                          },
                        )
                        : customTextButton(
                          text: "Sign In",
                          onPressed: () async {
                            bool success = await signIn();
                            if (success) {
                              // get our user from fireAuth
                              final user =
                                  firebaseAuthService.value.currentUser;
                              // set our user session parameters
                              if (user != null) {
                                UserSession().uid = user.uid;
                                UserSession().email = user.email;
                              }
                              // navigate to home/map page
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => Nav()),
                              );
                            }
                          },
                        ),
              ),
              // newly added to display error message, can change location
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10,
                  ),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  setState(() {
                    signUp = !signUp;
                  });
                },
                child:
                    signUp
                        ? Text(
                          "Already have an account? Sign In",
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        )
                        : Text(
                          "New to TRA\$H? Sign Up",
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* ------------------------ Functions Below --------------------------- */
  Future<bool> register() async {
    return await authFacade.register(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      name: nameController.text.trim(),
      postalCode: postalCodeController.text.trim(),
      onError: (msg) => setState(() => errorMessage = msg),
    );
  }

  Future<bool> signIn() async {
    return await authFacade.signIn(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      onError: (msg) => setState(() => errorMessage = msg),
    );
  }
}
