import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login_view extends StatefulWidget {
  const Login_view({Key? key}) : super(key: key);

  @override
  State<Login_view> createState() => Login_viewState();
}

class Login_viewState extends State<Login_view> {
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
      appBar: AppBar(title: const Text("Login"),
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
                final userCredential = await FirebaseAuth.instance
                    .signInWithEmailAndPassword(email: email, password: password);
                print(userCredential);
              } on FirebaseAuthException catch (e) {
                if (e.code == "user-not-found") {
                  print("User not found");
                } else if (e.code != password) {
                  print("wrong password");
                }
              }
            },
            child: const Text("Login"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/register/', (route) => false);
            },
            child: const Text("Not Registered Yet? Register here! "),
          )
        ],
      ),
    );
  }
}
