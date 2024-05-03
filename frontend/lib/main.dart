import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:logger/logger.dart';
import 'package:tooGoodToWaste/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:tooGoodToWaste/frame.dart';
import 'package:tooGoodToWaste/pages/login_signup.dart';
import 'package:tooGoodToWaste/service/db_helper.dart';
import 'package:tooGoodToWaste/service/push_notifications.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  await PushNotificationsManager().initNotifications();

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(const TooGoodToWaste());
}

class TooGoodToWaste extends StatelessWidget {
  const TooGoodToWaste({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.logEvent(name: "Start Application");

    return MaterialApp(
      title: 'Too Good To Waste',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Logger logger = Logger();

  // Checks whether we are logged in or not
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (userChangeContext, userChangeSnapshot) {
          return StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (authChangeContext, authChangeSnapshot) {
                if (authChangeSnapshot.connectionState ==
                    ConnectionState.active) {
                  User? user = authChangeSnapshot.data;

                  user ??= userChangeSnapshot.data;

                  logger.d('State of the login is $user');
                  if (user == null) {
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
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 210, 252, 194)),
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
    } while (strength < 1.0);

    return MaterialColor(color.value, swatch);
  }
}
