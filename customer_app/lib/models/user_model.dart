class AppUser {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? profileImageUrl;
  final List<Map<String, dynamic>> addresses;
  final double walletBalance;

  AppUser({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.profileImageUrl,
    this.addresses = const [],
    this.walletBalance = 0.0,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String id) => AppUser(
    id: id,
    name: map['name'] ?? '',
    phone: map['phone'] ?? '',
    email: map['email'],
    profileImageUrl: map['profileImageUrl'],
    addresses: List<Map<String, dynamic>>.from(map['addresses'] ?? []),
    walletBalance: (map['walletBalance'] ?? 0).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'name': name, 'phone': phone, 'email': email,
    'profileImageUrl': profileImageUrl,
    'addresses': addresses, 'walletBalance': walletBalance,
  };
}
