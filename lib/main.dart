import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';
import 'package:notes/services/auth/firebase_auth_provider.dart';
import 'package:notes/views/verify_email_view.dart';
import 'package:notes/views/register_view.dart';
import 'package:notes/views/login_view.dart';
import 'package:notes/views/notes/notes_view.dart';
import 'package:notes/views/notes/create_update_note_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(FirebaseAuthProvider()),
      child: const HomePage(),
    ),
    routes: {
      createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoading) {
          return const CircularProgressIndicator();
        }
        if (state is AuthStateLoggedOut) {
          return const LoginView();
        }
        if (state is AuthStateAuthenticated) {
          return const NotesView();
        }
        if (state is AuthStateNeedVerification) {
          return const VerifyEmailView();
        }
        if (state is AuthStateRegistering) {
          return const RegisterView();
        }
        return const Scaffold(
          body: CircularProgressIndicator(),
        );
      },
    );
  }
}
