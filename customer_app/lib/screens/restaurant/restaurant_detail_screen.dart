import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_router.dart';
import '../../models/restaurant_model.dart';
import '../../models/food_item_model.dart';
import '../../services/cart_service.dart';
import '../../widgets/food_item_card.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;
  const RestaurantDetailScreen({super.key, required this.restaurantId});
  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final CartService _cart = CartService();
  String _selectedCat = 'All';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('restaurants').doc(widget.restaurantId).snapshots(),
      builder: (ctx, snap) {
        if (!snap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
        final restaurant = Restaurant.fromMap(snap.data!.data() as Map<String, dynamic>, snap.data!.id);
        return Scaffold(
          body: CustomScrollView(slivers: [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(fit: StackFit.expand, children: [
                  Image.network(restaurant.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.divider, child: const Icon(Icons.restaurant, size: 60, color: AppColors.textHint))),
                  Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black26, Colors.black54]))),
                ]),
              ),
              leading: CircleAvatar(backgroundColor: Colors.white, radius: 18, child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20)),
            ),
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(restaurant.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(restaurant.cuisineType, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 12),
                Row(children: [
                  _InfoChip(icon: Icons.star_rounded, text: '${restaurant.rating}', color: AppColors.success),
                  const SizedBox(width: 8),
                  _InfoChip(icon: Icons.access_time_rounded, text: restaurant.deliveryTime),
                  const SizedBox(width: 8),
                  _InfoChip(icon: Icons.delivery_dining_rounded, text: restaurant.deliveryFee == 0 ? 'Free delivery' : 'Rs ${restaurant.deliveryFee.toInt()} delivery'),
                ]),
                if (restaurant.offers.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, children: restaurant.offers.map((o) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(6)),
                    child: Text(o, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500)),
                  )).toList()),
                ],
              ]),
            )),
            // Menu
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('food_items').where('restaurantId', isEqualTo: widget.restaurantId).snapshots(),
              builder: (ctx, snap) {
                if (!snap.hasData) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: AppColors.primary)));
                final items = snap.data!.docs.map((d) => FoodItem.fromMap(d.data() as Map<String, dynamic>, d.id)).toList();
                final cats = ['All', ...items.map((i) => i.category).toSet()];
                final filtered = _selectedCat == 'All' ? items : items.where((i) => i.category == _selectedCat).toList();
                return SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(height: 44, child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: cats.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => FilterChip(
                      label: Text(cats[i]),
                      selected: _selectedCat == cats[i],
                      onSelected: (_) => setState(() => _selectedCat = cats[i]),
                      selectedColor: AppColors.primaryLight,
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(color: _selectedCat == cats[i] ? AppColors.primary : AppColors.textPrimary, fontSize: 13),
                    ),
                  )),
                  const SizedBox(height: 8),
                  ...filtered.map((item) => FoodItemCard(item: item, cartService: _cart, onCartChanged: () => setState(() {}))),
                  const SizedBox(height: 100),
                ]));
              },
            ),
          ]),
          floatingActionButton: ValueListenableBuilder<int>(
            valueListenable: _cart.totalItemsNotifier,
            builder: (_, count, __) => count == 0 ? const SizedBox.shrink() : Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRouter.cart),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  CircleAvatar(radius: 12, backgroundColor: Colors.white30, child: Text('$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                  const Text('View Cart'),
                  Text('Rs ${_cart.totalPrice.toStringAsFixed(0)}'),
                ]),
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _InfoChip({required this.icon, required this.text, this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 16, color: color ?? AppColors.textSecondary),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color ?? AppColors.textSecondary)),
    ]),
  );
}
