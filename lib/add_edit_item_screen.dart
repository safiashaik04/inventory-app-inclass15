import 'package:flutter/material.dart';
import 'models/item.dart';
import 'services/firestore_service.dart';

class AddEditItemScreen extends StatefulWidget {
  final Item? item;
  const AddEditItemScreen({super.key, this.item});

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _quantityController.text = widget.item!.quantity.toString();
      _priceController.text = widget.item!.price.toString();
      _categoryController.text = widget.item!.category;
    }
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      final newItem = Item(
        id: widget.item?.id,
        name: _nameController.text,
        quantity: int.parse(_quantityController.text),
        price: double.parse(_priceController.text),
        category: _categoryController.text,
        createdAt: DateTime.now(),
      );

      if (widget.item == null) {
        await firestoreService.addItem(newItem);
      } else {
        await firestoreService.updateItem(newItem);
      }
      Navigator.pop(context);
    }
  }

  void _deleteItem() async {
    if (widget.item != null) {
      await firestoreService.deleteItem(widget.item!.id!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Item' : 'Add Item')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter item name' : null,
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Enter quantity' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value!.isEmpty ? 'Enter price' : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter category' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveItem,
                child: Text(isEdit ? 'Update' : 'Save'),
              ),
              if (isEdit)
                TextButton(
                  onPressed: _deleteItem,
                  child: const Text('Delete Item',
                      style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
