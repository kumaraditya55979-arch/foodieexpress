import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/theme.dart';
import 'orders_screen.dart';
import 'menu_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _State();
}
class _State extends State<DashboardScreen> {
  int _idx = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: _idx, children: const [_HomeTab(), OrdersScreen(), MenuScreen()]),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _idx,
      onDestinationSelected: (i) => setState(() => _idx = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
        NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long_rounded), label: 'Orders'),
        NavigationDestination(icon: Icon(Icons.restaurant_menu_outlined), selectedIcon: Icon(Icons.restaurant_menu_rounded), label: 'Menu'),
      ],
    ),
  );
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'), actions: [
        IconButton(icon: const Icon(Icons.logout_rounded), onPressed: () async {
          await FirebaseAuth.instance.signOut();
          if (context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        }),
      ]),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (ctx, snap) {
          final orders = snap.data?.docs ?? [];
          final total = orders.fold<double>(0, (s, d) => s + ((d.data() as Map)['total'] ?? 0.0));
          final active = orders.where((d) => (d.data() as Map)['statusIndex'] < 4).length;
          final delivered = orders.where((d) => (d.data() as Map)['statusIndex'] == 4).length;
          return ListView(padding: const EdgeInsets.all(16), children: [
            _StatCard(label: 'Total Revenue', value: 'Rs ${total.toStringAsFixed(0)}', icon: Icons.currency_rupee_rounded, color: AdminTheme.success),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _StatCard(label: 'Active Orders', value: '$active', icon: Icons.pending_actions_rounded, color: AdminTheme.warning)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'Delivered', value: '$delivered', icon: Icons.check_circle_rounded, color: AdminTheme.success)),
            ]),
            const SizedBox(height: 12),
            _StatCard(label: 'Total Orders', value: '${orders.length}', icon: Icons.receipt_long_rounded, color: AdminTheme.primary),
            const SizedBox(height: 24),
            const Text('Recent Orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...orders.take(5).map((o) {
              final data = o.data() as Map<String, dynamic>;
              final statusColors = [Colors.blue, Colors.orange, Colors.purple, Colors.teal, AdminTheme.success, Colors.red];
              final statusLabels = ['Placed', 'Confirmed', 'Preparing', 'On the way', 'Delivered', 'Cancelled'];
              final si = data['statusIndex'] ?? 0;
              return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
                leading: CircleAvatar(backgroundColor: statusColors[si].withOpacity(0.1), child: Icon(Icons.receipt_rounded, color: statusColors[si], size: 20)),
                title: Text(data['restaurantName'] ?? 'Order', style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text('Rs ${data['total']?.toStringAsFixed(0) ?? '0'}'),
                trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: statusColors[si].withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text(statusLabels[si], style: TextStyle(color: statusColors[si], fontSize: 11, fontWeight: FontWeight.w600))),
              ));
            }),
          ]);
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
    Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
    const SizedBox(width: 12),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AdminTheme.textPrimary)),
    ]),
  ])));
}
