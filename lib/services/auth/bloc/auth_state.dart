import 'package:flutter/foundation.dart' show immutable;
import 'package:notes/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

class AuthStateAuthenticated extends AuthState {
  final AuthUser user;
  const AuthStateAuthenticated(this.user);
}

class AuthStateNeedVerification extends AuthState {
  final AuthUser user;
  const AuthStateNeedVerification(this.user);
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateError extends AuthState {
  final Exception exception;
  const AuthStateError(this.exception);
}

class AuthStateLoggedOut extends AuthState {
  const AuthStateLoggedOut();
}
