import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Avatar
        Center(child: Column(children: [
          CircleAvatar(radius: 40, backgroundColor: AppColors.primaryLight, child: Text(user?.displayName?.substring(0,1) ?? 'U', style: const TextStyle(fontSize: 32, color: AppColors.primary, fontWeight: FontWeight.w700))),
          const SizedBox(height: 12),
          Text(user?.displayName ?? 'User', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Text(user?.phoneNumber ?? '', style: const TextStyle(color: AppColors.textSecondary)),
        ])),
        const SizedBox(height: 24),
        _MenuTile(icon: Icons.location_on_outlined, title: 'Saved Addresses', onTap: () {}),
        _MenuTile(icon: Icons.receipt_long_outlined, title: 'Order History', onTap: () {}),
        _MenuTile(icon: Icons.account_balance_wallet_outlined, title: 'Wallet & Payments', onTap: () {}),
        _MenuTile(icon: Icons.star_border_rounded, title: 'Ratings & Reviews', onTap: () {}),
        _MenuTile(icon: Icons.help_outline_rounded, title: 'Help & Support', onTap: () {}),
        _MenuTile(icon: Icons.info_outline_rounded, title: 'About App', onTap: () {}),
        const SizedBox(height: 8),
        _MenuTile(icon: Icons.logout_rounded, title: 'Logout', color: AppColors.error, onTap: () async {
          await FirebaseAuth.instance.signOut();
          if (context.mounted) Navigator.pushReplacementNamed(context, AppRouter.login);
        }),
      ]),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;
  const _MenuTile({required this.icon, required this.title, required this.onTap, this.color});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: Icon(icon, color: color ?? AppColors.textSecondary),
      title: Text(title, style: TextStyle(color: color ?? AppColors.textPrimary, fontWeight: FontWeight.w500)),
      trailing: color == null ? const Icon(Icons.chevron_right_rounded, color: AppColors.textHint) : null,
      onTap: onTap,
    ),
  );
}
