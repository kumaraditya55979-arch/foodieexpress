import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Order #${orderId.substring(0,6).toUpperCase()}')),
    body: const Center(child: Text('Order details')),
  );
}
