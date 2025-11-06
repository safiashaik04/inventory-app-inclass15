import 'package:flutter/material.dart';
import 'models/item.dart';
import 'services/firestore_service.dart';
import 'add_edit_item_screen.dart';
import 'inventory_dashboard.dart';

class InventoryHomePage extends StatefulWidget {
  const InventoryHomePage({super.key});

  @override
  State<InventoryHomePage> createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  final firestoreService = FirestoreService();
  String searchQuery = '';
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InventoryDashboard()),
              );
            },
            icon: const Icon(Icons.dashboard, color: Colors.black),
            label: const Text(
              'Dashboard',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Search Field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by item name...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value.toLowerCase());
              },
            ),
          ),

          // 🏷️ Category Filter Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: StreamBuilder<List<Item>>(
              stream: firestoreService.getItemsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final categories = snapshot.data!
                    .map((e) => e.category)
                    .toSet()
                    .toList();
                categories.insert(0, 'All');

                return DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() => selectedCategory = value!);
                  },
                  items: categories
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ))
                      .toList(),
                );
              },
            ),
          ),

          // 📦 Items List
          Expanded(
            child: StreamBuilder<List<Item>>(
              stream: firestoreService.getItemsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No items found.'));
                }

                final items = snapshot.data!
                    .where((item) =>
                        item.name.toLowerCase().contains(searchQuery) &&
                        (selectedCategory == 'All' ||
                            item.category == selectedCategory))
                    .toList();

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text(
                          'Qty: ${item.quantity} • \$${item.price} • ${item.category}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => firestoreService.deleteItem(item.id!),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddEditItemScreen(item: item),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddEditItemScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
