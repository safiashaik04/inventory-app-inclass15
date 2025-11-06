import 'package:flutter/material.dart';
import 'models/item.dart';
import 'services/firestore_service.dart';

class InventoryDashboard extends StatelessWidget {
  const InventoryDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Dashboard')),
      body: StreamBuilder<List<Item>>(
        stream: firestoreService.getItemsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;
          final totalItems = items.length;
          final totalValue = items.fold<double>(
              0, (sum, item) => sum + (item.price * item.quantity));
          final outOfStock =
              items.where((item) => item.quantity == 0).toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.inventory, color: Colors.blue),
                    title: const Text('Total Items'),
                    trailing: Text('$totalItems'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading:
                        const Icon(Icons.attach_money, color: Colors.green),
                    title: const Text('Total Inventory Value'),
                    trailing:
                        Text('\$${totalValue.toStringAsFixed(2)}'),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Out of Stock Items',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Divider(),
                if (outOfStock.isEmpty)
                  const Text('No out-of-stock items 🎉')
                else
                  ...outOfStock.map((item) => ListTile(
                        title: Text(item.name),
                        subtitle: Text(item.category),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }
}
