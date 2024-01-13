import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<StatefulWidget> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<AccountPage> {
  User? user;
  Logger logger = Logger();

  @override
  void initState() {
    _checkLoginState();
    super.initState();
  }

  void _checkLoginState() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      logger.d(user);
      setState(() {
        user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user != null) {
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
          FilledButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
                } on FirebaseAuthException catch (e) {
                  logger.e(e);
                }
              },
              child: const Text('Login')
          ),
          const SizedBox(height: 10,),
          TextButton(
              onPressed: () async {
              try {
                await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
              } on FirebaseAuthException catch (e) {
                logger.e(e);
              }
            },
          child: const Text('Sign Up'))
        ],
      ),
    );
  }
}

class AccountSettingPage extends StatefulWidget {
  const AccountSettingPage({super.key});

  @override
  State<StatefulWidget> createState() => _AccountSettingPageState();
}

class _AccountSettingPageState extends State<AccountSettingPage> {
  User? user;

  @override
  void initState() {
    user = FirebaseAuth.instance.currentUser;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Name', textAlign: TextAlign.start,),
          Text('${FirebaseAuth.instance.currentUser?.displayName}')
        ],
      ),
    );
  }

}