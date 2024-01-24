import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tooGoodToWaste/Pages/home.dart';
import 'package:tooGoodToWaste/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:tooGoodToWaste/frame.dart';
import 'package:tooGoodToWaste/pages/login_signup.dart';
import 'package:tooGoodToWaste/service/db_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(const TooGoodToWaste());
}

class TooGoodToWaste extends StatelessWidget {
  const TooGoodToWaste({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Too Good To Waste',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: MyApp(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Checks whether we are logged in or not
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            if (true) {
              return const LoginSignUpPage();
            } else {
              return MyApp();
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

class MyApp extends StatelessWidget {
  late final BuildContext context;
  final DBHelper dbhelper = DBHelper();
  final DateTime timeNowDate = DateTime.now();
  final int timeNow = DateTime.now().millisecondsSinceEpoch;

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return MaterialApp(
      title: 'Too Good To Waste',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const Frame(),
    );
  }

  MaterialColor createMaterialColor(Color color) {
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    double strength = .05;
    do {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
      strength = strength == .05 ? 0.1 : strength + 0.1;
    } while(strength < 1.0);

    return MaterialColor(color.value, swatch);
  }
  
}
