import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Background message handler — top-level function hona chahiye
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // App band ho tab bhi notification aayegi
  print('Background message: ${message.notification?.title}');
}

class NotificationService {
  static final _fcm = FirebaseMessaging.instance;
  static final _localNotif = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Permission maango (Android 13+)
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // Background handler register karo
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Local notifications setup (for foreground)
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotif.initialize(
      const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: (details) {},
    );

    // High importance channel banana zaroori hai Android pe
    const channel = AndroidNotificationChannel(
      'food_orders',
      'Food Orders',
      description: 'New order alerts',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );
    await _localNotif
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Foreground mein notification dikhao
    await _fcm.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

    // Jab app open ho aur notification aaye
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notif = message.notification;
      if (notif == null) return;

      _localNotif.show(
        notif.hashCode,
        notif.title,
        notif.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'food_orders',
            'Food Orders',
            channelDescription: 'New order alerts',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
          ),
        ),
      );
    });

    // FCM token save karo Firestore mein
    await _saveFcmToken();

    // Token refresh hone par update karo
    _fcm.onTokenRefresh.listen(_saveToken);
  }

  static Future<void> _saveFcmToken() async {
    final token = await _fcm.getToken();
    if (token != null) await _saveToken(token);
  }

  static Future<void> _saveToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('delivery_boys')
        .doc(uid)
        .set({'fcmToken': token}, SetOptions(merge: true));
  }
}
