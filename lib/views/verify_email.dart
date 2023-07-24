import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whoops4/constant/routes.dart';
import 'package:whoops4/services/auth/auth_services.dart';
import 'package:whoops4/services/auth/bloc/auth_bloc.dart';
import 'package:whoops4/services/auth/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
                "We've already sent you a verification Email, Please verify your account."),
            const Text(
                "If you haven't receive a verification email yet, press the button below"),
            TextButton(
              onPressed: () {
                context
                    .read<AuthBloc>()
                    .add(const AuthEventSendEmailVerification());
              },
              child: const Text("send Email verification"),
            ),
            TextButton(
                onPressed: () async {
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                },
                child: const Text("Restart"))
          ],
        ),
      ),
    );
  }
}
