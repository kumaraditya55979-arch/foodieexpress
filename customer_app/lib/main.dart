import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utils/app_theme.dart';
import 'utils/app_router.dart';
import 'screens/auth/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.init(); // FCM setup
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(const FoodApp());
}

class FoodApp extends StatelessWidget {
  const FoodApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FoodieExpress',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.theme,
    onGenerateRoute: AppRouter.generateRoute,
    home: const SplashScreen(),
  );
}
