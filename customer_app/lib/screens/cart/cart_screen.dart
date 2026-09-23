import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_router.dart';
import '../../services/cart_service.dart';
import '../../models/order_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cart = CartService();
  final _couponCtrl = TextEditingController();
  double _discount = 0;
  bool _placing = false;
  String _payMethod = 'COD';

  Future<void> _placeOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _cart.items.isEmpty) return;
    setState(() => _placing = true);
    try {
      final sub = _cart.totalPrice;
      final delivery = sub > 299 ? 0.0 : 40.0;
      final total = sub + delivery - _discount;
      final orderRef = await FirebaseFirestore.instance.collection('orders').add({
        'userId': user.uid,
        'restaurantId': _cart.restaurantId,
        'restaurantName': _cart.restaurantName,
        'items': _cart.items.map((ci) => {'name': ci.item.name, 'price': ci.item.effectivePrice, 'qty': ci.quantity, 'isVeg': ci.item.isVeg}).toList(),
        'subtotal': sub,
        'deliveryFee': delivery,
        'discount': _discount,
        'total': total,
        'statusIndex': 0,
        'deliveryAddress': 'Home, Sector 15',
        'createdAt': DateTime.now().toIso8601String(),
        'paymentMethod': _payMethod,
        'isPaid': _payMethod != 'COD',
      });
      _cart.clear();
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.tracking, arguments: orderRef.id);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order failed: $e')));
    }
    setState(() => _placing = false);
  }

  @override
  Widget build(BuildContext context) {
    final items = _cart.items;
    final sub = _cart.totalPrice;
    final delivery = sub > 299 ? 0.0 : 40.0;
    final total = sub + delivery - _discount;

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart'), leading: const BackButton()),
      body: items.isEmpty
          ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.shopping_cart_outlined, size: 80, color: AppColors.textHint),
              SizedBox(height: 16),
              Text('Your cart is empty', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
            ]))
          : Column(children: [
              Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
                ...items.map((ci) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)),
                  child: Row(children: [
                    Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 10), decoration: BoxDecoration(color: ci.item.isVeg ? AppColors.green : AppColors.error, shape: BoxShape.circle)),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(ci.item.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                      Text('Rs ${ci.item.effectivePrice.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ])),
                    Row(children: [
                      _QBtn(icon: Icons.remove, onTap: () { _cart.decrement(ci.item); setState(() {}); }),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('${ci.quantity}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
                      _QBtn(icon: Icons.add, onTap: () { _cart.increment(ci.item); setState(() {}); }, filled: true),
                    ]),
                  ]),
                )),
                // Coupon
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)),
                  child: Row(children: [
                    const Icon(Icons.local_offer_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: _couponCtrl, decoration: const InputDecoration(hintText: 'Enter coupon code', border: InputBorder.none, fillColor: Colors.transparent, filled: false))),
                    TextButton(onPressed: () { if (_couponCtrl.text == 'FIRST50') setState(() => _discount = 50); }, child: const Text('Apply', style: TextStyle(color: AppColors.primary))),
                  ]),
                ),
                const SizedBox(height: 16),
                // Bill
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)),
                  child: Column(children: [
                    _BillRow(label: 'Subtotal', value: 'Rs ${sub.toStringAsFixed(0)}'),
                    _BillRow(label: 'Delivery fee', value: delivery == 0 ? 'FREE' : 'Rs ${delivery.toInt()}'),
                    if (_discount > 0) _BillRow(label: 'Discount', value: '- Rs ${_discount.toInt()}', color: AppColors.success),
                    const Divider(height: 20),
                    _BillRow(label: 'Total', value: 'Rs ${total.toStringAsFixed(0)}', bold: true),
                  ]),
                ),
                const SizedBox(height: 16),
                // Payment
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 12),
                    ...['COD', 'UPI', 'Card'].map((m) => RadioListTile<String>(
                      title: Text(m == 'COD' ? 'Cash on Delivery' : m == 'UPI' ? 'UPI / GPay / PhonePe' : 'Credit / Debit Card'),
                      value: m, groupValue: _payMethod,
                      onChanged: (v) => setState(() => _payMethod = v!),
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                    )),
                  ]),
                ),
              ])),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.divider))),
                child: ElevatedButton(
                  onPressed: _placing ? null : _placeOrder,
                  child: _placing
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Place Order · Rs ${total.toStringAsFixed(0)}'),
                ),
              ),
            ]),
    );
  }
}

class _QBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _QBtn({required this.icon, required this.onTap, this.filled = false});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28, height: 28,
      decoration: BoxDecoration(color: filled ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.primary)),
      child: Icon(icon, size: 16, color: filled ? Colors.white : AppColors.primary),
    ),
  );
}

class _BillRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  final Color? color;
  const _BillRow({required this.label, required this.value, this.bold = false, this.color});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w600 : FontWeight.w400, color: bold ? AppColors.textPrimary : AppColors.textSecondary)),
      Text(value, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w500, color: color ?? (bold ? AppColors.textPrimary : AppColors.textSecondary))),
    ]),
  );
}
