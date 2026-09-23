import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _bgHandler(RemoteMessage message) async {}

class NotificationService {
  static final _fcm = FirebaseMessaging.instance;
  static final _localNotif = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);
    FirebaseMessaging.onBackgroundMessage(_bgHandler);

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotif.initialize(const InitializationSettings(android: android));

    const channel = AndroidNotificationChannel(
      'order_updates', 'Order Updates',
      description: 'Your food order status updates',
      importance: Importance.max,
      playSound: true,
    );
    await _localNotif
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _fcm.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

    // Foreground notification show karo
    FirebaseMessaging.onMessage.listen((msg) {
      final n = msg.notification;
      if (n == null) return;
      _localNotif.show(
        n.hashCode, n.title, n.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'order_updates', 'Order Updates',
            importance: Importance.max, priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    });

    // Token save
    final token = await _fcm.getToken();
    if (token != null) _saveToken(token);
    _fcm.onTokenRefresh.listen(_saveToken);
  }

  static Future<void> _saveToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users').doc(uid)
        .set({'fcmToken': token}, SetOptions(merge: true));
  }
}
