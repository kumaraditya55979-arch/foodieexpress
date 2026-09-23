import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/theme.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});
  @override
  State<MenuScreen> createState() => _State();
}
class _State extends State<MenuScreen> {
  void _showAddDialog([Map<String, dynamic>? existing, String? docId]) {
    final name = TextEditingController(text: existing?['name'] ?? '');
    final desc = TextEditingController(text: existing?['description'] ?? '');
    final price = TextEditingController(text: existing?['price']?.toString() ?? '');
    final cat = TextEditingController(text: existing?['category'] ?? '');
    final restId = TextEditingController(text: existing?['restaurantId'] ?? '');
    bool isVeg = existing?['isVeg'] ?? true;

    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (ctx, ss) => AlertDialog(
      title: Text(docId == null ? 'Add Menu Item' : 'Edit Item'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Item Name')),
        const SizedBox(height: 8),
        TextField(controller: desc, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
        const SizedBox(height: 8),
        TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (Rs)')),
        const SizedBox(height: 8),
        TextField(controller: cat, decoration: const InputDecoration(labelText: 'Category (Pizza/Burger/Chowmin)')),
        const SizedBox(height: 8),
        TextField(controller: restId, decoration: const InputDecoration(labelText: 'Restaurant ID')),
        const SizedBox(height: 8),
        Row(children: [
          const Text('Veg'), Switch(value: isVeg, onChanged: (v) => ss(() => isVeg = v), activeColor: AdminTheme.success),
          const Spacer(),
          Text(isVeg ? '🟢 Veg' : '🔴 Non-veg'),
        ]),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36)),
          onPressed: () {
            final data = {'name': name.text, 'description': desc.text, 'price': double.tryParse(price.text) ?? 0, 'category': cat.text, 'restaurantId': restId.text, 'isVeg': isVeg, 'rating': 4.0, 'ratingCount': 0, 'imageUrl': '', 'isBestseller': false};
            if (docId == null) FirebaseFirestore.instance.collection('food_items').add(data);
            else FirebaseFirestore.instance.collection('food_items').doc(docId).update(data);
            Navigator.pop(context);
          },
          child: Text(docId == null ? 'Add' : 'Update'),
        ),
      ],
    )));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Menu Management')),
    floatingActionButton: FloatingActionButton.extended(onPressed: () => _showAddDialog(), backgroundColor: AdminTheme.primary, icon: const Icon(Icons.add), label: const Text('Add Item')),
    body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('food_items').snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AdminTheme.primary));
        final items = snap.data?.docs ?? [];
        if (items.isEmpty) return const Center(child: Text('No menu items yet', style: TextStyle(color: AdminTheme.textSecondary)));
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final data = items[i].data() as Map<String, dynamic>;
            return Card(child: ListTile(
              leading: CircleAvatar(backgroundColor: (data['isVeg'] == true ? AdminTheme.success : AdminTheme.secondary).withOpacity(0.1), child: Icon(Icons.fastfood_rounded, color: data['isVeg'] == true ? AdminTheme.success : AdminTheme.secondary, size: 20)),
              title: Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text('${data['category'] ?? ''} · Rs ${data['price'] ?? 0}'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit_rounded, size: 20), onPressed: () => _showAddDialog(data, items[i].id), color: AdminTheme.primary),
                IconButton(icon: const Icon(Icons.delete_rounded, size: 20), onPressed: () => FirebaseFirestore.instance.collection('food_items').doc(items[i].id).delete(), color: AdminTheme.secondary),
              ]),
            ));
          },
        );
      },
    ),
  );
}
