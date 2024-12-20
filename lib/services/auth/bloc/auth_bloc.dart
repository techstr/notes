import 'package:bloc/bloc.dart';
import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()) {
    on<AuthEventInitialize>((event, emit) async {
      emit(const AuthStateLoading());
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(null));
      } else if (!user.isEmailVerified) {
        emit(AuthStateNeedVerification(user));
      } else {
        emit(AuthStateAuthenticated(user));
      }
    });
    on<AuthEventSignIn>((event, emit) async {
      try {
        final user = await provider.login(
          email: event.email,
          password: event.password,
        );
        if (!user.isEmailVerified) {
          emit(AuthStateNeedVerification(user));
        } else {
          emit(AuthStateAuthenticated(user));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(e));
      }
    });
    on<AuthEventSignOut>((event, emit) async {
      try {
        await provider.logout();
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(e));
      }
      emit(const AuthStateLoggedOut(null));
    });
    on<AuthEventSignUp>((event, emit) async {
      try {
        final user = await provider.createUser(
          email: event.email,
          password: event.password,
        );
        await provider.sendEmailVerification();
        emit(AuthStateNeedVerification(user));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(e));
      }
    });
  }
}
