import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  String? id;
  String name;
  int quantity;
  double price;
  String category;
  DateTime createdAt;

  Item({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.category,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Item.fromMap(String id, Map<String, dynamic> map) {
    return Item(
      id: id,
      name: map['name'],
      quantity: map['quantity'],
      price: map['price'].toDouble(),
      category: map['category'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
