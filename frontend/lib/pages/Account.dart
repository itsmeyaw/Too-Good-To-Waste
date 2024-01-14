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
  Widget build(BuildContext context) {
    return StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              User? user = snapshot.data;
              if (user == null) {
                return AccountLoginPage();
              } else {
                return AccountSettingPage(user: user);
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
      }
    });
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

class AccountSettingPage extends StatelessWidget {
  final User user;
  const AccountSettingPage({
    super.key,
    required this.user
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        height: MediaQuery.of(context).size.height,
        child: ListView(
          children: [
            const SizedBox(height: 10,),
            Text('Personal Information', style: Theme.of(context).textTheme.headlineSmall,),
            const SizedBox(height: 5,),
            const Text('Name'),
            Text('${user.displayName}', style: Theme.of(context).textTheme.bodyLarge,),
            const SizedBox(height: 10,),
            const Text('E-Mail'),
            Text('${user.email}', style: Theme.of(context).textTheme.bodyLarge,),
            const SizedBox(height: 20,),
            Text('Achievements', style: Theme.of(context).textTheme.headlineSmall,),
            const SizedBox(height: 5,),
            const Text('GoodPoints'),
            Text('120', style: Theme.of(context).textTheme.bodyLarge,),
            const SizedBox(height: 10,),
            const Text('Carbon Emission Saved'),
            Text('2 kg', style: Theme.of(context).textTheme.bodyLarge,),

          ],
        )
    );
  }
}