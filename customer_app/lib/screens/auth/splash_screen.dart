import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    Navigator.pushReplacementNamed(context, user != null ? AppRouter.mainNav : AppRouter.onboarding);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.fastfood_rounded, color: AppColors.primary, size: 56),
            ),
            const SizedBox(height: 20),
            const Text('FoodieExpress', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
            const SizedBox(height: 8),
            const Text('Food delivered fast', style: TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Poppins')),
          ]),
        ),
      ),
    );
  }
}
