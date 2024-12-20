import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventSignIn extends AuthEvent {
  final String email;
  final String password;
  const AuthEventSignIn(this.email, this.password);
}

class AuthEventSignOut extends AuthEvent {
  const AuthEventSignOut();
}

class AuthEventSignUp extends AuthEvent {
  final String email;
  final String password;
  const AuthEventSignUp(this.email, this.password);
}

class AuthEventVerifyEmail extends AuthEvent {
  const AuthEventVerifyEmail();
}

class AuthEventShouldSignUp extends AuthEvent {
  const AuthEventShouldSignUp();
}
