import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:tooGoodToWaste/main.dart';
import 'package:tooGoodToWaste/pages/inventory.dart';
import 'package:tooGoodToWaste/service/user_location_service.dart';


Future<void> handleBackgroundMessage(RemoteMessage message) async {
    final Logger logger = Logger();
    
    logger.d("Title: ${message.notification?.title}");
    logger.d("Body: ${message.notification?.body}");
    logger.d("Data: ${message.data}");
   
  }

class PushNotificationsManager {

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'Expired Food Alert!', // title
    description: 'Your .... is Expired!', // description
    importance: Importance.high,
  );

  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

 

  void handleMessage(RemoteMessage? message) {
    if ( message == null) return;

    navigatorKey.currentState?.pushNamed(
      Inventory.route, arguments: message
    );
  }

  Future initLocalNotifications() async {
    // const iOS = IOSInitializationSettings();
    const AndroidInitializationSettings android = AndroidInitializationSettings('@drawable/ic_launcher');
    
    var InitializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
      
      }
    );

    const settings = InitializationSettings(android: android);

    await _flutterLocalNotificationsPlugin.initialize(
      settings, 
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        
      }
    );

    final platform = _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  notificationDetails(){
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel', 
        'Expired Food Alert!', 
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
  }

  Future showNotification({int id = 0, String? title, String? body, String? payload}) async {
    return _flutterLocalNotificationsPlugin.show(id, title, body, await notificationDetails());
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((Message) {
        final notification = Message.notification;
        if (notification == null) return; 
        
        _flutterLocalNotificationsPlugin.show(
          notification.hashCode, 
          notification.title, 
          notification.body, 
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: '@drawable/ic_launcher',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          payload: jsonEncode(Message.toMap()),
        );
        
     });
  }

  Future<void> initNotifications() async {
    final Logger logger = Logger();

    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    // logger.d("fCMToken: $fCMToken");

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    initPushNotifications();
    initLocalNotifications();


  //   _firebaseMessaging.subscribeToTopic("all");
  }
}
