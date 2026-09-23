import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const CategoryChip({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
      ),
      child: Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontWeight: selected ? FontWeight.w600 : FontWeight.w400, fontSize: 13)),
    ),
  );
}
