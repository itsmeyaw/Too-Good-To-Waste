import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
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
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            toolbarHeight: 0,
            bottom: const TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.person_outline),
                  text: 'Pers. Info',
                ),
                Tab(
                  icon: Icon(Icons.stars_outlined),
                  text: 'Achievements',
                ),
                Tab(
                  icon: Icon(Icons.notifications_active_outlined),
                  text: 'Active Posts',
                )
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                height: MediaQuery.of(context).size.height,
                child: ListView(
                        children: [
                        const SizedBox(height: 10,),
                        const Text('Name'),
                        RichText(
                            text: TextSpan(
                              text: 'Empty',
                              style: Theme.of(context).textTheme.bodyLarge,
                            )
                        ),
                        const SizedBox(height: 10,),
                        const Text('E-Mail'),
                        Text('${user.email}', style: Theme.of(context).textTheme.bodyLarge,),
                        const SizedBox(height: 20,),
                      ]
                    ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                height: MediaQuery.of(context).size.height,
                child: ListView(
                    children: [
                      const SizedBox(height: 10,),
                      const Text('GoodPoints'),
                      Text('120', style: Theme.of(context).textTheme.bodyLarge,),
                      const SizedBox(height: 10,),
                      const Text('Carbon Emission Reduced'),
                      Text('2 kg', style: Theme.of(context).textTheme.bodyLarge,),
                      const SizedBox(height: 20,),
                    ]
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                height: MediaQuery.of(context).size.height,
                child: ListView(
                    children: const [
                      SizedBox(height: 10,),
                      Text('You have no active post currently'),
                    ]
                ),
              )
            ],
          ),
      )
    );
  }
}