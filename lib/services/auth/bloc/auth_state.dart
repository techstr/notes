import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:notes/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  const AuthState({
    required this.isLoading,
    this.loadingText = 'Please wait a moment...',
  });
}

class AuthStateUnInitialized extends AuthState {
  const AuthStateUnInitialized({required super.isLoading});
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering(
      {required super.isLoading, required this.exception});
}

class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated({required super.isLoading});
}

class AuthStateAuthenticated extends AuthState {
  final AuthUser user;
  const AuthStateAuthenticated({required this.user, required super.isLoading});
}

class AuthStateNeedVerification extends AuthState {
  const AuthStateNeedVerification({required super.isLoading});
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  const AuthStateLoggedOut({
    required this.exception,
    required super.isLoading,
    super.loadingText,
  });

  @override
  List<Object?> get props => [exception, isLoading];
}
