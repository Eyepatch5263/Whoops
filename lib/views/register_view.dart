import 'package:flutter/material.dart';
import 'package:whoops4/constant/routes.dart';
import 'package:whoops4/services/auth/auth_services.dart';
import 'package:whoops4/services/auth_exception.dart';
import 'package:whoops4/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: "Enter Your Email"),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: "Enter Your password"),
          ),
          TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                try {
                  await AuthService.firebase().createUSer(
                    email: email,
                    password: password,
                  );

                  AuthService.firebase().sendEmailVerification();
                  Navigator.of(context).pushNamed(verifyEmailRoute);
                } on WeakPasswordFoundAuthException {
                  await showErrorDialog(
                    context,
                    "Weak Password",
                  );
                } on EmailLAreadyInUserAuthException {
                  await showErrorDialog(
                    context,
                    "Email Already exists",
                  );
                } on InvalidEmailAuthException {
                  await showErrorDialog(
                    context,
                    "Invalid-Email",
                  );
                } on GenericAuthException {
                  await showErrorDialog(context, "Failed to register ");
                }
              },
              child: const Text("Register")),
          TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, loginRoute, (route) => false);
            },
            child: const Text("Already Registered? Login In here! "),
          )
        ],
      ),
    );
  }
}
