import 'package:bloc/bloc.dart';
import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUnInitialized(isLoading: true)) {
    on<AuthEventInitialize>((event, emit) async {
      emit(const AuthStateUnInitialized(isLoading: true));
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(isLoading: false, exception: null));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedVerification(isLoading: false));
      } else {
        emit(AuthStateAuthenticated(user: user, isLoading: false));
      }
    });

    on<AuthEventSignIn>((event, emit) async {
      emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: true,
          loadingText: 'Please wait while logging in..'));
      try {
        final user = await provider.login(
          email: event.email,
          password: event.password,
        );
        if (!user.isEmailVerified) {
          emit(const AuthStateNeedVerification(isLoading: false));
        } else {
          emit(AuthStateAuthenticated(user: user, isLoading: false));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });

    on<AuthEventSignOut>((event, emit) async {
      const AuthStateLoggedOut(
          exception: null,
          isLoading: true,
          loadingText: 'Please wait while logging out..');

      try {
        await provider.logout();
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });

    on<AuthEventSignUp>((event, emit) async {
      emit(const AuthStateRegistering(
          exception: null,
          isLoading: true,
          loadingText: 'Please wait while registering..'));
      try {
        await provider.createUser(
          email: event.email,
          password: event.password,
        );
        await provider.sendEmailVerification();
        emit(const AuthStateNeedVerification(isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateRegistering(exception: e, isLoading: false));
      }
    });

    on<AuthEventShouldSignUp>((event, emit) async {
      emit(const AuthStateRegistering(isLoading: false, exception: null));
    });

    on<AuthEventVerifyEmail>((event, emit) async {
      emit(const AuthStateNeedVerification(isLoading: true));
      await provider.sendEmailVerification();
      emit(const AuthStateNeedVerification(isLoading: false));
    });

    on<AuthEventForgotPassword>((event, emit) async {
      emit(const AuthStateForgotPassword(
          exception: null, hasSendEmail: false, isLoading: true));

      try {
        await provider.sendPasswordResetEmail(email: event.email);
        emit(const AuthStateForgotPassword(
            exception: null, hasSendEmail: true, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateForgotPassword(
            exception: e, hasSendEmail: false, isLoading: false));
      }
    });
  }
}
