import 'package:flutter/material.dart';
import 'models/item.dart';
import 'services/firestore_service.dart';
import 'add_edit_item_screen.dart';
import 'inventory_dashboard.dart';
import 'services/auth_service.dart';

class InventoryHomePage extends StatefulWidget {
  final bool isAdmin; // 👈 Added role-based flag
  const InventoryHomePage({super.key, required this.isAdmin});

  @override
  State<InventoryHomePage> createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  final firestoreService = FirestoreService();
  final authService = AuthService();
  String searchQuery = '';
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        actions: [
          // Dashboard Button with icon + text
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 400),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const InventoryDashboard(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    final tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: Curves.easeInOut));
                    return SlideTransition(position: animation.drive(tween), child: child);
                  },
                ),
              );
            },
            icon: const Icon(Icons.dashboard, color: Colors.black),
            label: const Text('Dashboard',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Show role info at top
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Role: ${widget.isAdmin ? 'Admin (Full Access)' : 'Viewer (Read-only)'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

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
                final categories =
                    snapshot.data!.map((e) => e.category).toSet().toList();
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
                      trailing: widget.isAdmin
                          ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  firestoreService.deleteItem(item.id!),
                            )
                          : null,
                      onTap: widget.isAdmin
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddEditItemScreen(item: item),
                                ),
                              )
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // ➕ Floating Action Button (Admins Only)
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditItemScreen(),
                ),
              ),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
