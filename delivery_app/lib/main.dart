import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utils/theme.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.init(); // FCM setup
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(const DeliveryApp());
}

class DeliveryApp extends StatelessWidget {
  const DeliveryApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FoodieExpress Partner',
    debugShowCheckedModeBanner: false,
    theme: DeliveryTheme.theme,
    home: const SplashScreen(),
  );
}
