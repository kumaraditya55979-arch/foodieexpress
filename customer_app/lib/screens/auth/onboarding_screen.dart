import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  final _pages = [
    _OnPage(icon: Icons.restaurant_menu_rounded, title: 'Order Anything', sub: 'Pizza, Burger, Chowmin and more — delivered to your door'),
    _OnPage(icon: Icons.delivery_dining_rounded, title: 'Fast Delivery', sub: 'Real-time tracking so you always know where your food is'),
    _OnPage(icon: Icons.local_offer_rounded, title: 'Best Offers', sub: 'Daily deals and discounts on your favourite restaurants'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, AppRouter.login),
              child: const Text('Skip', style: TextStyle(color: AppColors.textSecondary)),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _ctrl,
              onPageChanged: (i) => setState(() => _page = i),
              itemCount: _pages.length,
              itemBuilder: (_, i) => _pages[i].build(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i) =>
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 24 : 8, height: 8,
                  decoration: BoxDecoration(
                    color: _page == i ? AppColors.primary : AppColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
              )),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_page < 2) {
                    _ctrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                  } else {
                    Navigator.pushReplacementNamed(context, AppRouter.login);
                  }
                },
                child: Text(_page < 2 ? 'Next' : 'Get Started'),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _OnPage {
  final IconData icon;
  final String title, sub;
  const _OnPage({required this.icon, required this.title, required this.sub});

  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 160, height: 160,
        decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
        child: Icon(icon, color: AppColors.primary, size: 80),
      ),
      const SizedBox(height: 40),
      Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 12),
      Text(sub, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.6)),
    ]),
  );
}
