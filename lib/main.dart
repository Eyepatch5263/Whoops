import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whoops4/constant/routes.dart';
import 'package:whoops4/helpers/loading/loading_screen.dart';
import 'package:whoops4/services/auth/bloc/auth_bloc.dart';
import 'package:whoops4/services/auth/bloc/auth_event.dart';
import 'package:whoops4/services/auth/bloc/auth_state.dart';
import 'package:whoops4/services/auth/firebase_auth_provider.dart';
import 'package:whoops4/views/forgot_password_view.dart';
import 'package:whoops4/views/login_view.dart';
import 'package:whoops4/views/notes/create_update_note_view.dart';
import 'package:whoops4/views/notes/notes_view.dart';
import 'package:whoops4/views/register_view.dart';
import 'package:whoops4/views/verify_email.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Whoops',
      theme: ThemeData(
          primarySwatch: Colors.purple,
          fontFamily: 'Georgia',
          inputDecorationTheme: const InputDecorationTheme(
            hintStyle: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            labelStyle: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          )),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? "Please wait a moment",
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
