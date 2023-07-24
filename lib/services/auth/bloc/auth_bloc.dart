import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whoops4/services/auth/auth_provider.dart';
import 'package:whoops4/services/auth/bloc/auth_event.dart';
import 'package:whoops4/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()) {
    on<AuthEventInitialize>(
      ((event, emit) async {
        await provider.initialize();
        final user = provider.currentUser;
        if (user == null) {
          emit(const AuthStateLogOut());
        } else if (!user.isEmailVerified) {
          emit(const AuthStateNeedsVerification());
        } else {
          emit(AuthStateLoggedIn(user));
        }
      }),
    );
    //log in
    on<AuthEventLogin>(
      ((event, emit) async {
        emit(AuthStateLoading());
        final email = event.email;
        final password = event.password;
        try {
          final user = await provider.logIn(
            email: email,
            password: password,
          );
          emit(AuthStateLoggedIn(user));
        } on Exception catch (e) {
          emit(AuthStateLoginFailure(e));
        }
      }),
    );
    on<AuthEvent>(
      (event, emit) async {
        emit(const AuthStateLoading());
        try {
          emit(const AuthStateLoading());
          await provider.logout();
          emit(const AuthStateLogOut());
        } on Exception catch (e) {
          emit(AuthStateLogOutFailure(e));
        }
      },
    );
  }
}
