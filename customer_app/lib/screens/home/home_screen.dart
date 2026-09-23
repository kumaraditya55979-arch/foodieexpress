import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_theme.dart';
import '../../models/food_item_model.dart';
import '../../widgets/food_item_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/offer_banner.dart';
import '../../widgets/shimmer_loader.dart';
import '../../services/cart_service.dart';
import '../cart/cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  final _searchCtrl = TextEditingController();
  String _search = '';

  // Ek hi dukaan — sirf categories
  final _categories = ['All', 'Pizza', 'Burger', 'Chowmin', 'Biryani', 'Snacks', 'Desserts'];

  // Shop info — Firebase se aayega
  Map<String, dynamic>? _shopInfo;

  @override
  void initState() {
    super.initState();
    _loadShopInfo();
  }

  Future<void> _loadShopInfo() async {
    final snap = await FirebaseFirestore.instance.collection('shop_info').doc('main').get();
    if (snap.exists && mounted) setState(() => _shopInfo = snap.data());
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            expandedHeight: 56,
            toolbarHeight: 56,
            title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Delivery to', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Row(children: const [
                Text('Home', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: AppColors.primary),
              ]),
            ]),
            actions: [
              // Cart icon with badge
              StreamBuilder<int>(
                stream: CartService().itemCountStream,
                builder: (ctx, snap) {
                  final count = snap.data ?? 0;
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                    child: Stack(children: [
                      const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.shopping_bag_outlined, color: AppColors.textPrimary)),
                      if (count > 0) Positioned(
                        right: 4, top: 4,
                        child: Container(
                          width: 16, height: 16,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          child: Text('$count', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ]),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async { setState(() {}); await _loadShopInfo(); },
          child: CustomScrollView(slivers: [
            SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Shop Banner ─────────────────────────────────
              if (_shopInfo != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFFFF6B6B)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_shopInfo!['name'] ?? 'FoodieExpress',
                          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text('${_shopInfo!['rating'] ?? '4.5'} · ${_shopInfo!['deliveryTime'] ?? '20-30 min'}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ]),
                      const SizedBox(height: 4),
                      Text(_shopInfo!['isOpen'] == true ? '🟢 Abhi Open Hai' : '🔴 Abhi Closed Hai',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                    ])),
                    const Icon(Icons.storefront_rounded, color: Colors.white30, size: 50),
                  ]),
                ),

              // ── Offer Banners ────────────────────────────────
              const SizedBox(height: 14),
              SizedBox(height: 120, child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => OfferBanner(index: i),
              )),

              // ── Search ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _search = v.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Pizza, Burger, Chowmin...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchCtrl.clear(); setState(() => _search = ''); })
                        : null,
                  ),
                ),
              ),

              // ── Categories ───────────────────────────────────
              const SizedBox(height: 14),
              SizedBox(height: 36, child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => CategoryChip(
                  label: _categories[i],
                  selected: _selectedCategory == _categories[i],
                  onTap: () => setState(() => _selectedCategory = _categories[i]),
                ),
              )),

              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _selectedCategory == 'All' ? 'Poora Menu' : '$_selectedCategory Menu',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 8),
            ])),

            // ── Food Items (direct from Firestore) ──────────────
            StreamBuilder<QuerySnapshot>(
              stream: _selectedCategory == 'All'
                  ? FirebaseFirestore.instance.collection('food_items').snapshots()
                  : FirebaseFirestore.instance.collection('food_items').where('category', isEqualTo: _selectedCategory).snapshots(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return SliverList(delegate: SliverChildBuilderDelegate((_, i) => const ShimmerCard(), childCount: 6));
                }
                var docs = snap.data?.docs ?? [];
                var items = docs.map((d) => FoodItem.fromMap(d.data() as Map<String, dynamic>, d.id)).toList();

                if (_search.isNotEmpty) {
                  items = items.where((f) =>
                    f.name.toLowerCase().contains(_search) ||
                    f.category.toLowerCase().contains(_search)
                  ).toList();
                }

                if (items.isEmpty) {
                  return const SliverToBoxAdapter(child: Center(child: Padding(
                    padding: EdgeInsets.all(60),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.no_food_rounded, size: 60, color: Color(0xFFCCCCCC)),
                      SizedBox(height: 12),
                      Text('Koi item nahi mila', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                    ]),
                  )));
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(delegate: SliverChildBuilderDelegate(
                    (_, i) => FoodItemCard(item: items[i]),
                    childCount: items.length,
                  )),
                );
              },
            ),
          ]),
        ),
      ),
    );
  }
}
