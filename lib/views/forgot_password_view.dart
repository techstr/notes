import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';
import 'package:notes/utilities/dialogs/error_dialog.dart';
import 'package:notes/utilities/dialogs/password_reset_email_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthStateForgotPassword) {
            if (state.hasSendEmail) {
              _controller.clear();
              await showPasswordResetEmailDialog(context);
            } else if (state.exception != null) {
              if (state.exception is UserNotFoundAuthException) {
                await showErrorDialog(
                    context: context, text: 'User not found!');
              } else if (state.exception is InvalidEmailAuthException) {
                await showErrorDialog(
                    context: context, text: 'Invalid email address');
              } else {
                await showErrorDialog(
                    context: context,
                    text:
                        'We could not process your request, please try again later');
              }
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Forgot Password'),
          ),
          body: Column(
            children: [
              TextField(
                controller: _controller,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  context
                      .read<AuthBloc>()
                      .add(AuthEventForgotPassword(email: _controller.text));
                },
                child: const Text('Send me a reset link'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventSignOut());
                },
                child: const Text('Back to login'),
              ),
            ],
          ),
        ));
  }
}
