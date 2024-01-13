import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<StatefulWidget> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<AccountPage> {
  bool isSignedIn = false;

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      isSignedIn = user != null;
    });

    if (!isSignedIn) {
      return AccountLoginPage();
    } else {
      return AccountSettingPage();
    }
  }
}

class AccountLoginPage extends StatelessWidget {
  final Logger logger = Logger();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  AccountLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('Login to your account', textAlign: TextAlign.start,),
          const SizedBox(height: 10,),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'E-mail'
            ),
          ),
          const SizedBox(height: 10,),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Password'
            ),
          ),
          const SizedBox(height: 10,),
          FilledButton(onPressed: () {
            try {
              FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
            } on FirebaseAuthException catch (e) {
              logger.e(e);
            }
          }, child: const Text('Login'))
        ],
      ),
    );
  }
}

class AccountSettingPage extends StatelessWidget {
  const AccountSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('You are logged in!');
  }
}
