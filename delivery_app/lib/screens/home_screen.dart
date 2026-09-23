import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/location_service.dart';
import '../utils/theme.dart';
import 'login_screen.dart';
import 'earnings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isOnline = false;
  int _idx = 0;
  final _locationService = LocationService();

  void _toggleOnline(bool val) async {
    setState(() => _isOnline = val);
    if (val) {
      await _locationService.startTracking(); // 1 sec interval start
    } else {
      await _locationService.stopTracking();  // stop & mark offline
    }
  }

  @override
  void dispose() {
    _locationService.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodieExpress Partner'),
        actions: [
          Row(children: [
            Text(
              _isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                color: _isOnline ? DeliveryTheme.success : DeliveryTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Switch(value: _isOnline, onChanged: _toggleOnline, activeColor: DeliveryTheme.success),
          ]),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(index: _idx, children: [
        _OrdersTab(uid: uid, isOnline: _isOnline),
        const EarningsScreen(),
        _ProfileTab(),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.delivery_dining_outlined), selectedIcon: Icon(Icons.delivery_dining_rounded), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet_rounded), label: 'Earnings'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  final String? uid;
  final bool isOnline;
  const _OrdersTab({this.uid, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    if (!isOnline) {
      return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.wifi_off_rounded, size: 80, color: Color(0xFFBBBBBB)),
        SizedBox(height: 16),
        Text('Abhi Offline Ho', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: DeliveryTheme.textSecondary)),
        SizedBox(height: 8),
        Text('Online ho jaao orders lene ke liye', style: TextStyle(color: DeliveryTheme.textSecondary)),
      ]));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('statusIndex', whereIn: [1, 2, 3])
          .where('deliveryBoyId', isEqualTo: uid)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: DeliveryTheme.primary));
        }
        final orders = snap.data?.docs ?? [];
        if (orders.isEmpty) {
          return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.inbox_rounded, size: 80, color: Color(0xFFBBBBBB)),
            SizedBox(height: 16),
            Text('Koi Active Order Nahi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: DeliveryTheme.textSecondary)),
            SizedBox(height: 8),
            Text('Naye orders yahan aayenge', style: TextStyle(color: DeliveryTheme.textSecondary)),
          ]));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final data = orders[i].data() as Map<String, dynamic>;
            final orderId = orders[i].id;
            final si = (data['statusIndex'] as int?) ?? 1;
            final statusLabels = ['', 'Confirmed', 'Preparing', 'On the way'];
            final nextBtnLabels = ['', 'Start Preparing', 'Pick Up Order', 'Mark Delivered'];

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('#${orderId.substring(0, 6).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: DeliveryTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        si < statusLabels.length ? statusLabels[si] : '',
                        style: const TextStyle(color: DeliveryTheme.primary, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  _InfoRow(icon: Icons.restaurant_rounded, text: data['restaurantName'] ?? ''),
                  const SizedBox(height: 4),
                  _InfoRow(icon: Icons.location_on_rounded, text: data['deliveryAddress'] ?? ''),
                  const SizedBox(height: 4),
                  _InfoRow(icon: Icons.currency_rupee_rounded, text: 'Rs ${data['total']?.toStringAsFixed(0) ?? '0'} · ${data['paymentMethod'] ?? 'COD'}'),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => launchUrl(Uri.parse('tel:${data['userPhone'] ?? ''}')),
                        icon: const Icon(Icons.call_rounded, size: 16),
                        label: const Text('Call Customer'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: DeliveryTheme.primary,
                          side: const BorderSide(color: DeliveryTheme.primary),
                          minimumSize: const Size(0, 42),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final next = (si + 1).clamp(1, 4);
                          FirebaseFirestore.instance
                              .collection('orders')
                              .doc(orderId)
                              .update({'statusIndex': next});
                        },
                        style: ElevatedButton.styleFrom(minimumSize: const Size(0, 42)),
                        child: Text(si < nextBtnLabels.length ? nextBtnLabels[si] : 'Done'),
                      ),
                    ),
                  ]),
                ]),
              ),
            );
          },
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon; final String text;
  const _InfoRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 14, color: DeliveryTheme.textSecondary),
    const SizedBox(width: 6),
    Expanded(child: Text(text, style: const TextStyle(color: DeliveryTheme.textSecondary, fontSize: 13), overflow: TextOverflow.ellipsis)),
  ]);
}

class _ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Center(child: Column(children: [
        const CircleAvatar(radius: 40, backgroundColor: Color(0xFFE8F0FE), child: Icon(Icons.person_rounded, size: 40, color: DeliveryTheme.primary)),
        const SizedBox(height: 12),
        Text(user?.displayName ?? 'Delivery Partner', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        Text(user?.phoneNumber ?? '', style: const TextStyle(color: DeliveryTheme.textSecondary)),
      ])),
      const SizedBox(height: 24),
      Card(child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text('Logout', style: TextStyle(color: Colors.red)),
        onTap: () async {
          await LocationService().stopTracking();
          await FirebaseAuth.instance.signOut();
          if (context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        },
      )),
    ]);
  }
}
