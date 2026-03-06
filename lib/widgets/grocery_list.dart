import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'flutter-prep-1ac10-default-rtdb.firebaseio.com',
        'shopping-list.json');

    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Please try again later.';
          _isLoading = false;
        });
        return;
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];

      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;
            
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }

      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
      
    } catch (error) {
      setState(() {
        _error = 'Something went wrong! Please try again later.';
        _isLoading = false;
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(
        'flutter-prep-1ac10-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete item. It was restored.')),
      );
    }
  }

  // ฟังก์ชันแปลงชื่อเป็นไอคอน!
  IconData _getIconFromName(String name) {
    final lowerName = name.toLowerCase();
    
    // น้ำๆ นมๆ
    if (lowerName.contains('milk') || lowerName.contains('นม') || lowerName.contains('drink')) {
      return Icons.local_drink;
    }
    // เนื้อสัตว์
    if (lowerName.contains('meat') || lowerName.contains('pork') || lowerName.contains('หมู') || lowerName.contains('ไก่')) {
      return Icons.set_meal;
    }
    // ไข่
    if (lowerName.contains('egg') || lowerName.contains('ไข่')) {
      return Icons.egg;
    }
    // ผัก
    if (lowerName.contains('veg') || lowerName.contains('ผัก') || lowerName.contains('carrot')) {
      return Icons.eco;
    }
    // ผลไม้
    if (lowerName.contains('fruit') || lowerName.contains('apple') || lowerName.contains('ผลไม้')) {
      return Icons.apple;
    }
    // เบเกอรี่ ขนมปัง
    if (lowerName.contains('bread') || lowerName.contains('ขนมปัง') || lowerName.contains('cake')) {
      return Icons.bakery_dining;
    }
    
    
    return Icons.shopping_bag;
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text('The basket is empty.!', style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      content = Center(child: Text(_error!));
    } else if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          background: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete_sweep, color: Colors.white, size: 30),
          ),
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Text(
                _groceryItems[index].name,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
              
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _groceryItems[index].category.color.withOpacity(0.2), 
                  borderRadius: BorderRadius.circular(12), 
                ),
                child: Icon(
                  _getIconFromName(_groceryItems[index].name),
                  color: _groceryItems[index].category.color, 
                  size: 24,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_groceryItems[index].quantity}x',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_basket_outlined),
            SizedBox(width: 8),
            Text('Your Groceries'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add_shopping_cart),
          ),
        ],
      ),
      body: content,
    );
  }
}