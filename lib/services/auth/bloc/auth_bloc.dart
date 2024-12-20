import 'package:bloc/bloc.dart';
import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()) {
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut());
      } else if (!user.isEmailVerified) {
        emit(AuthStateNeedVerification(user));
      } else {
        emit(AuthStateAuthenticated(user));
      }
    });
    on<AuthEventSignIn>((event, emit) async {
      emit(const AuthStateLoading());
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
        emit(AuthStateError(e));
      }
    });
    on<AuthEventSignOut>((event, emit) async {
      emit(const AuthStateLoading());
      try {
        await provider.logout();
      } on Exception catch (e) {
        emit(AuthStateError(e));
      }
      emit(const AuthStateLoggedOut());
    });
    on<AuthEventSignUp>((event, emit) async {
      emit(const AuthStateLoading());
      try {
        final user = await provider.createUser(
          email: event.email,
          password: event.password,
        );
        await provider.sendEmailVerification();
        emit(AuthStateNeedVerification(user));
      } on Exception catch (e) {
        emit(AuthStateError(e));
      }
    });
  }
}
