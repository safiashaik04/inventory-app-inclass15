import 'package:flutter/material.dart';
import 'models/item.dart';
import 'services/firestore_service.dart';
import 'add_edit_item_screen.dart';

class InventoryHomePage extends StatelessWidget {
  const InventoryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Management')),
      body: StreamBuilder<List<Item>>(
        stream: firestoreService.getItemsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No items found.'));
          }

          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text(
                    'Qty: ${item.quantity} • Price: \$${item.price.toStringAsFixed(2)} • ${item.category}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => firestoreService.deleteItem(item.id!),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditItemScreen(item: item),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddEditItemScreen(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
