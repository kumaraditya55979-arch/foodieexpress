class Restaurant {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String cuisineType;
  final double rating;
  final int ratingCount;
  final String deliveryTime;
  final double deliveryFee;
  final double minOrder;
  final String address;
  final double lat;
  final double lng;
  final bool isOpen;
  final List<String> offers;
  final String ownerId;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.cuisineType,
    required this.rating,
    required this.ratingCount,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.minOrder,
    required this.address,
    required this.lat,
    required this.lng,
    required this.isOpen,
    required this.offers,
    required this.ownerId,
  });

  factory Restaurant.fromMap(Map<String, dynamic> map, String id) => Restaurant(
    id: id,
    name: map['name'] ?? '',
    description: map['description'] ?? '',
    imageUrl: map['imageUrl'] ?? '',
    cuisineType: map['cuisineType'] ?? '',
    rating: (map['rating'] ?? 0).toDouble(),
    ratingCount: map['ratingCount'] ?? 0,
    deliveryTime: map['deliveryTime'] ?? '30-45 min',
    deliveryFee: (map['deliveryFee'] ?? 0).toDouble(),
    minOrder: (map['minOrder'] ?? 0).toDouble(),
    address: map['address'] ?? '',
    lat: (map['lat'] ?? 0).toDouble(),
    lng: (map['lng'] ?? 0).toDouble(),
    isOpen: map['isOpen'] ?? true,
    offers: List<String>.from(map['offers'] ?? []),
    ownerId: map['ownerId'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'name': name, 'description': description, 'imageUrl': imageUrl,
    'cuisineType': cuisineType, 'rating': rating, 'ratingCount': ratingCount,
    'deliveryTime': deliveryTime, 'deliveryFee': deliveryFee, 'minOrder': minOrder,
    'address': address, 'lat': lat, 'lng': lng, 'isOpen': isOpen,
    'offers': offers, 'ownerId': ownerId,
  };
}
