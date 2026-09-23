import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_router.dart';
import '../../models/order_model.dart';

class OrdersListScreen extends StatelessWidget {
  const OrdersListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: uid == null ? const Center(child: Text('Login to view orders')) : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').where('userId', isEqualTo: uid).orderBy('createdAt', descending: true).snapshots(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          final orders = snap.data?.docs.map((d) => Order.fromMap(d.data() as Map<String, dynamic>, d.id)).toList() ?? [];
          if (orders.isEmpty) return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.receipt_long_outlined, size: 80, color: AppColors.textHint),
            SizedBox(height: 16),
            Text('No orders yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          ]));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final o = orders[i];
              final isActive = o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled;
              return GestureDetector(
                onTap: () => isActive ? Navigator.pushNamed(context, AppRouter.tracking, arguments: o.id) : null,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(o.restaurantName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: o.status == OrderStatus.delivered ? AppColors.success.withOpacity(0.1) : o.status == OrderStatus.cancelled ? AppColors.error.withOpacity(0.1) : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(o.statusText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: o.status == OrderStatus.delivered ? AppColors.success : o.status == OrderStatus.cancelled ? AppColors.error : AppColors.primary)),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Text('${o.items.length} items · Rs ${o.total.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    if (isActive) ...[
                      const SizedBox(height: 10),
                      ElevatedButton(onPressed: () => Navigator.pushNamed(context, AppRouter.tracking, arguments: o.id), style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)), child: const Text('Track Order')),
                    ],
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
