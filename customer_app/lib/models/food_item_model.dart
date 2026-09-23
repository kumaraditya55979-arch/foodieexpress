class FoodItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountedPrice;
  final String imageUrl;
  final String category;
  final bool isVeg;
  final bool isBestseller;
  final double rating;
  final int ratingCount;
  final String restaurantId;
  final List<String> tags;
  int quantity;

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountedPrice,
    required this.imageUrl,
    required this.category,
    required this.isVeg,
    this.isBestseller = false,
    this.rating = 4.0,
    this.ratingCount = 0,
    required this.restaurantId,
    this.tags = const [],
    this.quantity = 0,
  });

  double get effectivePrice => discountedPrice ?? price;
  bool get hasDiscount => discountedPrice != null && discountedPrice! < price;
  int get discountPercent => hasDiscount ? (((price - discountedPrice!) / price) * 100).round() : 0;

  factory FoodItem.fromMap(Map<String, dynamic> map, String id) {
    return FoodItem(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      discountedPrice: map['discountedPrice']?.toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      isVeg: map['isVeg'] ?? true,
      isBestseller: map['isBestseller'] ?? false,
      rating: (map['rating'] ?? 4.0).toDouble(),
      ratingCount: map['ratingCount'] ?? 0,
      restaurantId: map['restaurantId'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name, 'description': description, 'price': price,
    'discountedPrice': discountedPrice, 'imageUrl': imageUrl,
    'category': category, 'isVeg': isVeg, 'isBestseller': isBestseller,
    'rating': rating, 'ratingCount': ratingCount, 'restaurantId': restaurantId,
    'tags': tags,
  };
}
