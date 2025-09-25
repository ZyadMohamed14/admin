import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_screen.dart';

// main.dart - Enhanced for background notifications
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// CRITICAL: This function runs when app is completely closed
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print('BACKGROUND MESSAGE: ${message.messageId}');
  print('BACKGROUND DATA: ${message.data}');

  // Show system notification even when app is closed
  await _showBackgroundNotification(message);
}

// Function to show system notification when app is closed
Future<void> _showBackgroundNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'admin_orders_channel',  // Channel ID
    'Admin Orders',          // Channel Name
    channelDescription: 'Notifications for new orders',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
    enableVibration: true,
    playSound: true,
    // Make notification persistent
    ongoing: false,
    autoCancel: true,
    // Show on lock screen
    visibility: NotificationVisibility.public,
    // Custom sound (optional)
    sound: RawResourceAndroidNotificationSound('notification_sound'),
  );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    ),
  );

  await flutterLocalNotificationsPlugin.show(
    message.hashCode, // Unique ID
    message.notification?.title ?? 'New Order',
    message.notification?.body ?? 'You have received a new order',
    platformChannelSpecifics,
    payload: message.data['order_id']?.toString(),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('Starting app initialization...');

  try {
    // Initialize Firebase first
    await Firebase.initializeApp();
    print('SUCCESS: Firebase initialized');

    // Set up background message handler FIRST (before any other Firebase operations)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    print('SUCCESS: Background handler registered');

    // Initialize notifications with proper channels
    await initializeNotifications();
    print('SUCCESS: Notifications initialized');

    // Set up foreground handlers
    await setupForegroundHandlers();
    print('SUCCESS: Foreground handlers set up');

    // Request permissions
    await requestNotificationPermissions();
    print('SUCCESS: Permissions requested');

  } catch (e) {
    print('ERROR: Initialization failed: $e');
  }

  runApp(MyApp());
}

Future<void> initializeNotifications() async {
  // Android notification channel for high priority notifications
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'admin_orders_channel',
    'Admin Orders',
    description: 'Notifications for new orders when app is closed',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  // Create the channel
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
  DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
   // onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
  );
}

// Handle notification tap when app is closed
void _onDidReceiveNotificationResponse(NotificationResponse response) async {
  print('Notification tapped: ${response.payload}');

  if (response.payload != null) {
    // Navigate to specific order if order_id is provided
    // This will be handled by your app's navigation logic
    print('Navigate to order: ${response.payload}');
  }
}

// iOS specific handler
void _onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async {
  print('iOS notification received: $title');
}

Future<void> setupForegroundHandlers() async {
  // Handle messages when app is in foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('FOREGROUND MESSAGE: ${message.messageId}');

    // Show notification even when app is open (for admin alerts)
    await _showForegroundNotification(message);
  });

  // Handle notification tap when app is in background (not closed)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('APP OPENED FROM NOTIFICATION: ${message.messageId}');
    _handleNotificationTap(message);
  });

  // Check for notification that opened the app initially
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    print('APP OPENED FROM TERMINATED STATE: ${initialMessage.messageId}');
    _handleNotificationTap(initialMessage);
  }
}

Future<void> _showForegroundNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'admin_orders_channel',
    'Admin Orders',
    channelDescription: 'New order notifications',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
    enableVibration: true,
    playSound: true,
  );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  await flutterLocalNotificationsPlugin.show(
    message.hashCode,
    message.notification?.title ?? 'New Order',
    message.notification?.body ?? 'You have received a new order',
    platformChannelSpecifics,
    payload: message.data['order_id']?.toString(),
  );
}

void _handleNotificationTap(RemoteMessage message) {
  // Handle navigation based on notification data
  if (message.data['order_id'] != null) {
    // Navigate to specific order details
    print('Should navigate to order: ${message.data['order_id']}');
  }
}

Future<void> requestNotificationPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: false,
    criticalAlert: true,
    provisional: false,
    sound: true,
  );

  print('Permission status: ${settings.authorizationStatus}');

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('SUCCESS: User granted notification permissions');

    // Get and log FCM token
    String? token = await messaging.getToken();
    if (token != null) {
      print('FCM TOKEN: $token');
      // Save token to shared preferences for API calls
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
    }

  } else {
    print('WARNING: User denied notification permissions');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Orders',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthWrapper(),
    );
  }
}