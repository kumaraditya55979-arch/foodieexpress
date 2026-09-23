import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utils/theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FoodieExpress Admin',
    debugShowCheckedModeBanner: false,
    theme: AdminTheme.theme,
    home: const SplashScreen(),
  );
}
