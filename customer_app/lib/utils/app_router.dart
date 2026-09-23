import 'package:flutter/material.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/main_nav_screen.dart';
import '../screens/restaurant/restaurant_detail_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/orders/order_detail_screen.dart';
import '../screens/tracking/tracking_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String mainNav = '/main';
  static const String restaurantDetail = '/restaurant';
  static const String cart = '/cart';
  static const String orderDetail = '/order-detail';
  static const String tracking = '/tracking';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _slide(const SplashScreen());
      case onboarding:
        return _slide(const OnboardingScreen());
      case login:
        return _slide(const LoginScreen());
      case otp:
        final phone = settings.arguments as String;
        return _slide(OtpScreen(phoneNumber: phone));
      case mainNav:
        return _slide(const MainNavScreen());
      case restaurantDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return _slide(RestaurantDetailScreen(restaurantId: args['id']));
      case cart:
        return _slide(const CartScreen());
      case tracking:
        final orderId = settings.arguments as String;
        return _slide(TrackingScreen(orderId: orderId));
      case profile:
        return _slide(const ProfileScreen());
      default:
        return _slide(const SplashScreen());
    }
  }

  static PageRouteBuilder _slide(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) =>
        SlideTransition(position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(anim), child: child),
    transitionDuration: const Duration(milliseconds: 300),
  );
}
