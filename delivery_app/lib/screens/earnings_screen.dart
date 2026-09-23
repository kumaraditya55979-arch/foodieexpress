import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/theme.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('My Earnings')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').where('deliveryBoyId', isEqualTo: uid).where('statusIndex', isEqualTo: 4).snapshots(),
        builder: (ctx, snap) {
          final orders = snap.data?.docs ?? [];
          double total = 0;
          for (final o in orders) { total += ((o.data() as Map)['deliveryFee'] ?? 40.0); }
          return ListView(padding: const EdgeInsets.all(16), children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [DeliveryTheme.primary, Color(0xFF1557B0)]), borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Total Earnings', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Text('Rs ${total.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('${orders.length} deliveries completed', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ]),
            ),
            const SizedBox(height: 16),
            ...orders.map((o) {
              final data = o.data() as Map<String, dynamic>;
              return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.check_rounded, color: DeliveryTheme.success)),
                title: Text(data['restaurantName'] ?? 'Order', style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(data['createdAt']?.toString().substring(0, 10) ?? '', style: const TextStyle(fontSize: 12)),
                trailing: Text('+ Rs ${(data['deliveryFee'] ?? 40).toStringAsFixed(0)}', style: const TextStyle(color: DeliveryTheme.success, fontWeight: FontWeight.w700)),
              ));
            }),
          ]);
        },
      ),
    );
  }
}
