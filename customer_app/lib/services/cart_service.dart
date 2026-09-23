import 'package:flutter/material.dart';
import '../models/food_item_model.dart';
import '../models/order_model.dart';

class CartService {
  static final CartService _instance = CartService._();
  factory CartService() => _instance;
  CartService._();

  final List<CartItem> _items = [];
  String _restaurantId = '';
  String _restaurantName = '';

  ValueNotifier<int> totalItemsNotifier = ValueNotifier(0);

  List<CartItem> get items => List.unmodifiable(_items);
  String get restaurantId => _restaurantId;
  String get restaurantName => _restaurantName;

  double get totalPrice => _items.fold(0, (sum, ci) => sum + ci.total);
  int get totalItems => _items.fold(0, (sum, ci) => sum + ci.quantity);

  void addItem(FoodItem item) {
    if (_restaurantId.isNotEmpty && _restaurantId != item.restaurantId) {
      _items.clear();
    }
    _restaurantId = item.restaurantId;
    final existing = _items.where((ci) => ci.item.id == item.id);
    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      _items.add(CartItem(item: item, quantity: 1));
    }
    item.quantity = _items.firstWhere((ci) => ci.item.id == item.id).quantity;
    _notify();
  }

  void increment(FoodItem item) { addItem(item); }

  void decrement(FoodItem item) {
    final idx = _items.indexWhere((ci) => ci.item.id == item.id);
    if (idx == -1) return;
    if (_items[idx].quantity > 1) {
      _items[idx].quantity--;
      item.quantity = _items[idx].quantity;
    } else {
      _items.removeAt(idx);
      item.quantity = 0;
    }
    _notify();
  }

  void clear() { _items.clear(); _restaurantId = ''; _restaurantName = ''; _notify(); }

  void _notify() { totalItemsNotifier.value = totalItems; }
}
