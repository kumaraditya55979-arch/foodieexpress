import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/theme.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _State();
}
class _State extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  @override
  void initState() { super.initState(); _tabs = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Orders'), bottom: TabBar(controller: _tabs, labelColor: AdminTheme.primary, unselectedLabelColor: AdminTheme.textSecondary, indicatorColor: AdminTheme.primary, tabs: const [Tab(text: 'Active'), Tab(text: 'Delivered'), Tab(text: 'Cancelled')])),
    body: TabBarView(controller: _tabs, children: [
      _OrderList(filter: (si) => si >= 0 && si < 4),
      _OrderList(filter: (si) => si == 4),
      _OrderList(filter: (si) => si == 5),
    ]),
  );
}

class _OrderList extends StatelessWidget {
  final bool Function(int) filter;
  const _OrderList({required this.filter});
  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('orders').orderBy('createdAt', descending: true).snapshots(),
    builder: (ctx, snap) {
      if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AdminTheme.primary));
      final all = snap.data?.docs ?? [];
      final orders = all.where((d) => filter((d.data() as Map)['statusIndex'] ?? 0)).toList();
      if (orders.isEmpty) return const Center(child: Text('No orders', style: TextStyle(color: AdminTheme.textSecondary)));
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final data = orders[i].data() as Map<String, dynamic>;
          final orderId = orders[i].id;
          final si = data['statusIndex'] ?? 0;
          final statusLabels = ['Placed', 'Confirmed', 'Preparing', 'On the way', 'Delivered', 'Cancelled'];
          return Card(child: ExpansionTile(
            title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('#${orderId.substring(0,6).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w700)),
              Text('Rs ${data['total']?.toStringAsFixed(0) ?? '0'}', style: const TextStyle(fontWeight: FontWeight.w600, color: AdminTheme.success)),
            ]),
            subtitle: Text('${data['restaurantName'] ?? ''} · ${statusLabels[si]}'),
            children: [
              Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Delivery: ${data['deliveryAddress'] ?? ''}', style: const TextStyle(fontSize: 13, color: AdminTheme.textSecondary)),
                const SizedBox(height: 4),
                Text('Payment: ${data['paymentMethod'] ?? 'COD'}', style: const TextStyle(fontSize: 13, color: AdminTheme.textSecondary)),
                if (si < 4) ...[
                  const SizedBox(height: 10),
                  Row(children: [
                    if (si < 3) Expanded(child: ElevatedButton(onPressed: () => FirebaseFirestore.instance.collection('orders').doc(orderId).update({'statusIndex': si + 1}), style: ElevatedButton.styleFrom(minimumSize: const Size(0, 38)), child: const Text('Advance'))),
                    const SizedBox(width: 8),
                    Expanded(child: OutlinedButton(onPressed: () => FirebaseFirestore.instance.collection('orders').doc(orderId).update({'statusIndex': 5}), style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), minimumSize: const Size(0, 38)), child: const Text('Cancel'))),
                  ]),
                ],
              ])),
            ],
          ));
        },
      );
    },
  );
}
