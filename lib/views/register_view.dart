import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as devtools show log;

import 'package:notes/constants/routes.dart';
import 'package:notes/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Column(
        children: [
          TextField(
              controller: _email,
              enableSuggestions: true,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'Enter your email')),
          TextField(
              controller: _password,
              obscureText: true,
              enableSuggestions: true,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'Enter your password',
              )),
          TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: email, password: password);
                  if (context.mounted) {
                    Navigator.of(context).pushNamed(verifyEmailRoute);
                  }
                } on FirebaseAuthException catch (e) {
                  if (context.mounted) {
                    switch (e.code) {
                      case 'weak-password':
                        await showErrorDialog(
                            context, "Please enter a strong password!");
                      case 'email-already-in-use':
                        await showErrorDialog(context,
                            "Email Already exists, login or use another email!");
                      case 'invalid-email':
                        await showErrorDialog(
                            context, "Invalid Email Entered!");
                      default:
                        await showErrorDialog(context, "Error : ${e.code}");
                    }
                  }
                }
              },
              child: const Text("Register")),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginRoute, (_) => false);
              },
              child: const Text("Already registered? Login here!")),
        ],
      ),
    );
  }
}
