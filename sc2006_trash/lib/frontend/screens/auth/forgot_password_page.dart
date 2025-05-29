import 'package:flutter/material.dart';
import 'package:flutter_create_test/backend/facades/auth_facade.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final AuthFacade _authFacade = AuthFacade();

  String message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002C93),
      appBar: AppBar(
        title: const Text(
          'Forgot Password',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF002C93),
      ),
      body: GestureDetector(
        onTap:
            () => FocusScope.of(context).unfocus(), // dismiss keyboard on tap
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 50),
                  const Text(
                    "Enter your email address and we'll send you a link to reset your password.",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white),
                      prefixIcon: Icon(Icons.email, color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: sendResetEmail,
                    child: const Text("Submit"),
                  ),
                  if (message.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      message,
                      style: const TextStyle(color: Colors.greenAccent),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const Spacer(), // pushes content up if there's space
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /* ------------------------ Functions Below --------------------------- */
  Future<void> sendResetEmail() async {
    String email = emailController.text.trim();

    setState(() {
      message = '';
    });

    await _authFacade.resetPassword(
      email: email,
      onSuccess: () {
        setState(() {
          message = 'Password reset email sent. Please check your inbox.';
        });
      },
      onError: (errorMsg) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text("Error"),
                content: Text(errorMsg),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
      },
    );
  }
}
