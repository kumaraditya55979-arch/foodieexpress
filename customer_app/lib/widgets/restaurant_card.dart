import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../models/restaurant_model.dart';
import '../utils/app_router.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  const RestaurantCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.pushNamed(context, AppRouter.restaurantDetail, arguments: {'id': restaurant.id}),
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Stack(children: [
            Image.network(restaurant.imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 160, color: AppColors.divider, child: const Icon(Icons.restaurant, size: 50, color: AppColors.textHint))),
            if (!restaurant.isOpen) Container(height: 160, color: Colors.black54, child: const Center(child: Text('Closed', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)))),
            if (restaurant.offers.isNotEmpty)
              Positioned(bottom: 8, left: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)), child: Text(restaurant.offers.first, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)))),
          ]),
        ),
        Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(restaurant.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(restaurant.cuisineType, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.star_rounded, size: 16, color: AppColors.success),
            const SizedBox(width: 4),
            Text('${restaurant.rating}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text(' (${restaurant.ratingCount}+)', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const Spacer(),
            const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(restaurant.deliveryTime, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(width: 12),
            const Icon(Icons.delivery_dining_rounded, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(restaurant.deliveryFee == 0 ? 'Free' : 'Rs ${restaurant.deliveryFee.toInt()}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ]),
        ])),
      ]),
    ),
  );
}
