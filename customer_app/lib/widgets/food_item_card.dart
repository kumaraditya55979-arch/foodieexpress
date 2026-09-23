import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../models/food_item_model.dart';
import '../services/cart_service.dart';

class FoodItemCard extends StatelessWidget {
  final FoodItem item;
  final CartService cartService;
  final VoidCallback onCartChanged;
  const FoodItemCard({super.key, required this.item, required this.cartService, required this.onCartChanged});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 14, height: 14, decoration: BoxDecoration(color: item.isVeg ? AppColors.green : AppColors.error, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          if (item.isBestseller) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.15), borderRadius: BorderRadius.circular(4)), child: const Text('Bestseller', style: TextStyle(fontSize: 10, color: AppColors.warning, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 6),
        Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 4),
        Text(item.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        Row(children: [
          Text('Rs ${item.effectivePrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          if (item.hasDiscount) ...[
            const SizedBox(width: 6),
            Text('Rs ${item.price.toStringAsFixed(0)}', style: const TextStyle(decoration: TextDecoration.lineThrough, color: AppColors.textHint, fontSize: 12)),
            const SizedBox(width: 4),
            Text('${item.discountPercent}% off', style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ]),
      ])),
      const SizedBox(width: 12),
      Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(item.imageUrl, width: 90, height: 90, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 90, height: 90, color: AppColors.divider, child: const Icon(Icons.fastfood_rounded, color: AppColors.textHint))),
        ),
        const SizedBox(height: 6),
        item.quantity == 0
            ? GestureDetector(
                onTap: () { cartService.addItem(item); onCartChanged(); },
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.primary)), child: const Text('ADD', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13))),
              )
            : Row(children: [
                _Btn(icon: Icons.remove, onTap: () { cartService.decrement(item); onCartChanged(); }),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                _Btn(icon: Icons.add, onTap: () { cartService.increment(item); onCartChanged(); }, filled: true),
              ]),
      ]),
    ]),
  );
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _Btn({required this.icon, required this.onTap, this.filled = false});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(width: 26, height: 26, decoration: BoxDecoration(color: filled ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(5), border: Border.all(color: AppColors.primary)), child: Icon(icon, size: 14, color: filled ? Colors.white : AppColors.primary)),
  );
}
