import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/theme.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _State();
}
class _State extends State<SplashScreen> {
  @override
  void initState() { super.initState(); Future.delayed(const Duration(seconds: 2), () { if (!mounted) return; final u = FirebaseAuth.instance.currentUser; Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => u != null ? const DashboardScreen() : const LoginScreen())); }); }
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: AdminTheme.primary, body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 90, height: 90, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.admin_panel_settings_rounded, color: AdminTheme.primary, size: 54)), const SizedBox(height: 20), const Text('FoodieExpress', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)), const Text('Admin Panel', style: TextStyle(color: Colors.white70))])));
}
