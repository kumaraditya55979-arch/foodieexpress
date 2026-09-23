import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/theme.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _State();
}
class _State extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email.text.trim(), password: _pass.text.trim());
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SizedBox(height: 40),
    const Icon(Icons.admin_panel_settings_rounded, color: AdminTheme.primary, size: 56),
    const SizedBox(height: 20),
    const Text('Admin Login', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
    const SizedBox(height: 8),
    const Text('FoodieExpress control panel', style: TextStyle(color: AdminTheme.textSecondary)),
    const SizedBox(height: 40),
    TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
    const SizedBox(height: 16),
    TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline))),
    const SizedBox(height: 24),
    ElevatedButton(onPressed: _loading ? null : _login, child: _loading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text('Login')),
  ]))));
}
