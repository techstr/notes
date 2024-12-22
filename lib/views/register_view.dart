import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';
import 'package:notes/utilities/dialogs/error_dialog.dart';

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateRegistering) {
          if (state is WeakPasswordAuthException) {
            showErrorDialog(context: context, text: "Weak password entered!");
          } else if (state is EmailAlreadyInUseAuthException) {
            showErrorDialog(context: context, text: "Email Already in Use!");
          } else if (state is InvalidEmailAuthException) {
            showErrorDialog(context: context, text: "Invalid Email Entered!");
          } else if (state is GenericAuthExceptions) {
            showErrorDialog(context: context, text: "Something went wrong!");
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                  controller: _email,
                  enableSuggestions: true,
                  autocorrect: false,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      const InputDecoration(hintText: 'Enter your email')),
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
                    context
                        .read<AuthBloc>()
                        .add(AuthEventSignUp(email, password));
                  },
                  child: const Text("Register")),
              TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthEventSignOut());
                  },
                  child: const Text("Already registered? Login here!")),
            ],
          ),
        ),
      ),
    );
  }
}
