// import 'dart:convert';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static Future<void> initialize() async {
//     // Local notification setup
//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings initSettings =
//         InitializationSettings(android: androidSettings);

//     await _localNotificationsPlugin.initialize(initSettings);

//     FirebaseMessaging messaging = FirebaseMessaging.instance;

//     // Skip topic subscription on web
//     if (!kIsWeb) {
//       await messaging.subscribeToTopic('all_users');
//     }

//     // Foreground handling
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//       final title = message.notification?.title ?? 'New Notification';
//       final body = message.notification?.body ?? '';
//       await _saveNotification(title, body);
//       _showNotification(title, body);
//     });

//     // Background handler
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   }

//   static Future<void> _saveNotification(String title, String body) async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> notifs = prefs.getStringList('notifications') ?? [];
//     notifs.add(jsonEncode({'title': title, 'body': body}));
//     await prefs.setStringList('notifications', notifs);
//   }

//   static Future<List<Map<String, String>>> getNotifications() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> stored = prefs.getStringList('notifications') ?? [];
//     return stored
//         .map((e) => Map<String, String>.from(jsonDecode(e)))
//         .toList();
//   }

//   static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//     await Firebase.initializeApp();
//     final title = message.notification?.title ?? 'New Notification';
//     final body = message.notification?.body ?? '';
//     await _saveNotification(title, body);
//   }

//   static Future<void> _showNotification(String title, String body) async {
//     const androidDetails = AndroidNotificationDetails(
//       'channel_id',
//       'Product Notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     const platformDetails = NotificationDetails(android: androidDetails);

//     await _localNotificationsPlugin.show(
//       DateTime.now().millisecondsSinceEpoch ~/ 1000,
//       title,
//       body,
//       platformDetails,
//     );
//   }
// }


import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _localNotificationsPlugin.initialize(initSettings);

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Skip topic subscription on web
    if (!kIsWeb) {
      await messaging.subscribeToTopic('all_users');
    }
    // await messaging.subscribeToTopic('all_users');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final title = message.notification?.title ?? 'New Notification';
      final body = message.notification?.body ?? '';
      await _saveNotification(title, body);
      _showNotification(title, body);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _saveNotification(String title, String body) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notifs = prefs.getStringList('notifications') ?? [];
    notifs.add(jsonEncode({'title': title, 'body': body}));
    await prefs.setStringList('notifications', notifs);
  }

  static Future<List<Map<String, String>>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> stored = prefs.getStringList('notifications') ?? [];
    return stored.map((e) => Map<String, String>.from(jsonDecode(e))).toList();
  }

  static Future<void> clearAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notifications');
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    final title = message.notification?.title ?? 'New Notification';
    final body = message.notification?.body ?? '';
    await _saveNotification(title, body);
  }

  static Future<void> _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Product Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const platformDetails = NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformDetails,
    );
  }
}