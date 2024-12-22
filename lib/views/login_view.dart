import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';
import 'package:notes/utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            showErrorDialog(context: context, text: "User not found!");
          } else if (state.exception is WrongPasswordAuthException) {
            showErrorDialog(context: context, text: "Wrong Credentials!");
          } else if (state.exception is InvalidEmailAuthException) {
            showErrorDialog(context: context, text: "Wrong Credentials!");
          } else if (state.exception is GenericAuthExceptions) {
            showErrorDialog(context: context, text: "Something went wrong!");
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              ElevatedButton(
                  onPressed: () async {
                    final email = _email.text;
                    final password = _password.text;
                    context.read<AuthBloc>().add(AuthEventSignIn(
                          email,
                          password,
                        ));
                  },
                  child: const Text("Login")),
              Center(
                child: Column(
                  children: [
                    TextButton(
                        onPressed: () {
                          context
                              .read<AuthBloc>()
                              .add(const AuthEventShouldSignUp());
                        },
                        child:
                            const Text("Not registered yet? Register here!")),
                    TextButton(
                        onPressed: () {
                          context
                              .read<AuthBloc>()
                              .add(const AuthEventForgotPassword(email: ""));
                        },
                        child: const Text("I forgot my password"))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
