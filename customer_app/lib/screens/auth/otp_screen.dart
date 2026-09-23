import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_router.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpCtrl = TextEditingController();
  String? _verificationId;
  bool _loading = false;
  bool _codeSent = false;

  @override
  void initState() { super.initState(); _sendOtp(); }

  Future<void> _sendOtp() async {
    setState(() => _loading = true);
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (cred) async {
        await FirebaseAuth.instance.signInWithCredential(cred);
        if (mounted) Navigator.pushReplacementNamed(context, AppRouter.mainNav);
      },
      verificationFailed: (e) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Verification failed')));
      },
      codeSent: (id, _) => setState(() { _verificationId = id; _loading = false; _codeSent = true; }),
      codeAutoRetrievalTimeout: (_) => setState(() => _loading = false),
    );
  }

  Future<void> _verifyOtp() async {
    if (_otpCtrl.text.length != 6 || _verificationId == null) return;
    setState(() => _loading = true);
    try {
      final cred = PhoneAuthProvider.credential(verificationId: _verificationId!, smsCode: _otpCtrl.text);
      await FirebaseAuth.instance.signInWithCredential(cred);
      if (mounted) Navigator.pushReplacementNamed(context, AppRouter.mainNav);
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wrong OTP. Try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 20),
          const Text('OTP Verification', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text('Enter the OTP sent to ${widget.phoneNumber}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 40),
          TextField(
            controller: _otpCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 12),
            decoration: InputDecoration(
              counterText: '',
              hintText: '------',
              hintStyle: TextStyle(letterSpacing: 12, color: AppColors.textHint),
            ),
            onChanged: (v) { if (v.length == 6) _verifyOtp(); },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _loading ? null : _verifyOtp,
            child: _loading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Verify OTP'),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: _codeSent ? _sendOtp : null,
              child: const Text('Resend OTP', style: TextStyle(color: AppColors.primary)),
            ),
          ),
        ]),
      ),
    );
  }
}
