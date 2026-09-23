import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/theme.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  String? _verificationId;
  bool _codeSent = false;
  bool _loading = false;

  Future<void> _sendOtp() async {
    setState(() => _loading = true);
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91${_phoneCtrl.text.trim()}',
      verificationCompleted: (cred) async {
        await FirebaseAuth.instance.signInWithCredential(cred);
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      },
      verificationFailed: (e) { setState(() => _loading = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Error'))); },
      codeSent: (id, _) => setState(() { _verificationId = id; _codeSent = true; _loading = false; }),
      codeAutoRetrievalTimeout: (_) => setState(() => _loading = false),
    );
  }

  Future<void> _verify() async {
    if (_verificationId == null) return;
    setState(() => _loading = true);
    try {
      final cred = PhoneAuthProvider.credential(verificationId: _verificationId!, smsCode: _otpCtrl.text.trim());
      await FirebaseAuth.instance.signInWithCredential(cred);
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (_) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wrong OTP')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 40),
        const Icon(Icons.delivery_dining_rounded, color: DeliveryTheme.primary, size: 56),
        const SizedBox(height: 20),
        const Text('Partner Login', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: DeliveryTheme.textPrimary)),
        const SizedBox(height: 8),
        const Text('Login to start accepting deliveries', style: TextStyle(color: DeliveryTheme.textSecondary)),
        const SizedBox(height: 40),
        if (!_codeSent) ...[
          TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, maxLength: 10, decoration: const InputDecoration(labelText: 'Phone Number', prefixText: '+91 ', counterText: '')),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _loading ? null : _sendOtp, child: _loading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text('Send OTP')),
        ] else ...[
          TextField(controller: _otpCtrl, keyboardType: TextInputType.number, maxLength: 6, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: 10), decoration: const InputDecoration(counterText: '', hintText: '------')),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _loading ? null : _verify, child: _loading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text('Verify & Login')),
        ],
      ]),
    )),
  );
}
