import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class OfferBanner extends StatelessWidget {
  final int index;
  const OfferBanner({super.key, required this.index});

  static const _offers = [
    _BannerData('50% OFF first order', 'Use code FIRST50', AppColors.primary, Color(0xFFFF6B6B)),
    _BannerData('Free delivery', 'On orders above Rs 299', Color(0xFF2ECC71), Color(0xFF27AE60)),
    _BannerData('New restaurant', 'Try something different', Color(0xFF9B59B6), Color(0xFF8E44AD)),
  ];

  @override
  Widget build(BuildContext context) {
    final d = _offers[index % _offers.length];
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [d.c1, d.c2], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(d.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(d.subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ]),
    );
  }
}

class _BannerData {
  final String title, subtitle;
  final Color c1, c2;
  const _BannerData(this.title, this.subtitle, this.c1, this.c2);
}
