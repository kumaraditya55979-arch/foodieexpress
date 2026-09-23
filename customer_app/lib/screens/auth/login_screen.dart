import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_router.dart';
import '../home/main_nav_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  bool _googleLoading = false;

  // ── Google Sign In ─────────────────────────────────────────────
  Future<void> _signInWithGoogle() async {
    setState(() => _googleLoading = true);
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) { setState(() => _googleLoading = false); return; }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = result.user;
      if (user == null) return;

      // Firestore mein user save karo
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'phone': user.phoneNumber ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavScreen()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google login failed: $e'), backgroundColor: Colors.red),
      );
    }
    if (mounted) setState(() => _googleLoading = false);
  }

  // ── Phone OTP ─────────────────────────────────────────────────
  Future<void> _sendOtp() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('10 digit phone number daalo')),
      );
      return;
    }
    setState(() => _loading = true);
    Navigator.pushNamed(context, AppRouter.otp, arguments: '+91$phone');
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 40),

            // Logo + Title
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.fastfood_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 20),
            const Text('FoodieExpress\nmein swagat hai! 🎉',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.3)),
            const SizedBox(height: 8),
            const Text('Login karke order karo!',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),

            const SizedBox(height: 40),

            // ── Google Button ─────────────────────────────────
            GestureDetector(
              onTap: _googleLoading ? null : _signInWithGoogle,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                ),
                child: _googleLoading
                    ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        // Google G logo
                        Container(
                          width: 22, height: 22,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                          child: const Text('G',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF4285F4))),
                        ),
                        const SizedBox(width: 10),
                        const Text('Google se login karo',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      ]),
              ),
            ),

            const SizedBox(height: 20),

            // ── Divider ───────────────────────────────────────
            Row(children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('ya', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ),
              const Expanded(child: Divider()),
            ]),

            const SizedBox(height: 20),

            // ── Phone Number ──────────────────────────────────
            const Text('Phone se login karo',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: const BoxDecoration(border: Border(right: BorderSide(color: AppColors.divider))),
                  child: const Text('+91', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
                Expanded(
                  child: TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: const InputDecoration(
                      hintText: 'Phone number',
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _loading ? null : _sendOtp,
              child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('OTP Bhejo'),
            ),

            const SizedBox(height: 24),
            const Center(
              child: Text('Login karke aap hamare Terms & Privacy Policy se agree karte hain',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ),
          ]),
        ),
      ),
    );
  }
}
