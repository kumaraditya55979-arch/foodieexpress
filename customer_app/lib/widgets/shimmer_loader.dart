import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/app_theme.dart';

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.divider,
    highlightColor: Colors.white,
    child: Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      height: 230,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
    ),
  );
}
