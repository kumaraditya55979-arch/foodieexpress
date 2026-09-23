import 'food_item_model.dart';

enum OrderStatus { placed, confirmed, preparing, onTheWay, delivered, cancelled }

class CartItem {
  final FoodItem item;
  int quantity;
  CartItem({required this.item, this.quantity = 1});
  double get total => item.effectivePrice * quantity;
}

class Order {
  final String id;
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final OrderStatus status;
  final String deliveryAddress;
  final String? deliveryBoyId;
  final String? deliveryBoyName;
  final String? deliveryBoyPhone;
  final double? deliveryBoyLat;
  final double? deliveryBoyLng;
  final DateTime createdAt;
  final String paymentMethod;
  final bool isPaid;

  Order({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.status,
    required this.deliveryAddress,
    this.deliveryBoyId,
    this.deliveryBoyName,
    this.deliveryBoyPhone,
    this.deliveryBoyLat,
    this.deliveryBoyLng,
    required this.createdAt,
    required this.paymentMethod,
    required this.isPaid,
  });

  String get statusText {
    switch (status) {
      case OrderStatus.placed: return 'Order Placed';
      case OrderStatus.confirmed: return 'Confirmed';
      case OrderStatus.preparing: return 'Preparing';
      case OrderStatus.onTheWay: return 'On the way';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }

  factory Order.fromMap(Map<String, dynamic> map, String id) => Order(
    id: id,
    userId: map['userId'] ?? '',
    restaurantId: map['restaurantId'] ?? '',
    restaurantName: map['restaurantName'] ?? '',
    items: List<Map<String, dynamic>>.from(map['items'] ?? []),
    subtotal: (map['subtotal'] ?? 0).toDouble(),
    deliveryFee: (map['deliveryFee'] ?? 0).toDouble(),
    discount: (map['discount'] ?? 0).toDouble(),
    total: (map['total'] ?? 0).toDouble(),
    status: OrderStatus.values[map['statusIndex'] ?? 0],
    deliveryAddress: map['deliveryAddress'] ?? '',
    deliveryBoyId: map['deliveryBoyId'],
    deliveryBoyName: map['deliveryBoyName'],
    deliveryBoyPhone: map['deliveryBoyPhone'],
    deliveryBoyLat: map['deliveryBoyLat']?.toDouble(),
    deliveryBoyLng: map['deliveryBoyLng']?.toDouble(),
    createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    paymentMethod: map['paymentMethod'] ?? 'COD',
    isPaid: map['isPaid'] ?? false,
  );
}
