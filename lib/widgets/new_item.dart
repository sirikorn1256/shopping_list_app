import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false;

  //เพิ่มลิสต์คำแนะนำสินค้า  (Autocomplete)
  final List<String> _suggestions = [
    'Egg', 'Milk', 'Meat', 'Bread', 'Apple', 'Banana', 'Rice', 'Water', 
    'Chicken', 'Pork', 'Carrot', 'Onion', 'Soap', 'Shampoo', 'Coke', 'Cake'
  ];

  // ฟังก์ชัน พิมพ์ชื่อปุ๊บ เลือกหมวดหมู่ให้อัตโนมัติ (Auto-Category Selection)
  void _autoSelectCategory(String name) {
    final lowerName = name.toLowerCase();
    Category? detectedCategory;

    // เช็คเงื่อนไขตามตัวอักษรที่ขึ้นต้น หรือคำที่พิมพ์
    if (lowerName.startsWith('m') || lowerName.contains('milk')) {
      detectedCategory = categories[Categories.dairy];
    } else if (lowerName.startsWith('e') || lowerName.contains('egg')) {
      detectedCategory = categories[Categories.dairy];
    } else if (lowerName.startsWith('me') || lowerName.contains('meat')) {
      detectedCategory = categories[Categories.meat];
    } else if (lowerName.startsWith('f') || lowerName.contains('fruit')) {
      detectedCategory = categories[Categories.fruit];
    } else if (lowerName.startsWith('v') || lowerName.contains('veg')) {
      detectedCategory = categories[Categories.vegetables];
    } else if (lowerName.startsWith('b') || lowerName.contains('bread')) {
      detectedCategory = categories[Categories.carbs];
    } else if (lowerName.startsWith('s') || lowerName.contains('soap')) {
      detectedCategory = categories[Categories.hygiene];
    }

    if (detectedCategory != null) {
      setState(() {
        _selectedCategory = detectedCategory!;
      });
    }
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });

      final url = Uri.https(
          'flutter-prep-1ac10-default-rtdb.firebaseio.com',
          'shopping-list.json');
      
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(
            {
              'name': _enteredName,
              'quantity': _enteredQuantity,
              'category': _selectedCategory.title,
            },
          ),
        );

        if (!mounted) return;

        final Map<String, dynamic> resData = json.decode(response.body);

        Navigator.of(context).pop(
          GroceryItem(
            id: resData['name'],
            name: _enteredName,
            quantity: _enteredQuantity,
            category: _selectedCategory,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
  }

  IconData _getIconForCategory(String title) {
    switch (title.toLowerCase()) {
      case 'vegetables': return Icons.eco;
      case 'fruit': return Icons.apple;
      case 'meat': return Icons.set_meal;
      case 'dairy': return Icons.local_drink;
      case 'carbs': return Icons.bakery_dining;
      case 'sweets': return Icons.cake;
      case 'spices': return Icons.local_fire_department;
      case 'convenience': return Icons.fastfood;
      case 'hygiene': return Icons.sanitizer;
      case 'other': return Icons.shopping_bag;
      default: return Icons.label;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // พื้นเทาอ่อนพาสเทล
      appBar: AppBar(
        backgroundColor: const Color(0xFFC4E4FF), // สีฟ้า NewJeans
        elevation: 0, 
        iconTheme: const IconThemeData(color: Colors.black87), 
        title: const Text(
          'Add a new item',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold), 
        ),
      ),
      body: SingleChildScrollView( 
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                LayoutBuilder(
                  builder: (context, constraints) => Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      // กรองเฉพาะคำที่ "ขึ้นต้นด้วย" (startsWith) ตัวอักษรที่พิมพ์
                      return _suggestions.where((String option) {
                        return option.toLowerCase().startsWith(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      _enteredName = selection;
                      _autoSelectCategory(selection); // เลือกหมวดหมู่ให้เองเมื่อจิ้มเลือกคำ
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        maxLength: 50,
                        decoration: InputDecoration(
                          hintText: 'Name', // 
                          prefixIcon: const Icon(Icons.shopping_bag_outlined, color: Colors.grey), 
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300), 
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5), 
                          ),
                          filled: true,
                          fillColor: Colors.white, 
                        ),
                        onChanged: (value) {
                          _autoSelectCategory(value); // เลือกหมวดหมู่ให้เอง "ขณะกำลังพิมพ์"
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty || value.trim().length <= 1) {
                            return 'Must be between 1 and 50 characters.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredName = value!;
                        },
                      );
                    },
                    // ตกแต่งหน้าตาลิสต์ที่เด้งลงมาเดาคำ
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4.0,
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: constraints.maxWidth, 
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (BuildContext context, int index) {
                                final String option = options.elementAt(index);
                                return ListTile(
                                  title: Text(option),
                                  onTap: () => onSelected(option),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Qty', 
                          prefixIcon: const Icon(Icons.numbers, color: Colors.grey), 
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: _enteredQuantity.toString(),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return 'Must be a valid, positive number.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredQuantity = int.parse(value!);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    Expanded(
                      child: DropdownButtonFormField(
                        isExpanded: true, 
                        decoration: InputDecoration(
                          hintText: 'Category', 
                          prefixIcon: const Icon(Icons.label_outline, color: Colors.grey), 
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        value: _selectedCategory,
                        
                        selectedItemBuilder: (BuildContext context) {
                          return categories.entries.map((category) {
                            return Text(
                              category.value.title,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.black87),
                            );
                          }).toList();
                        },
                       
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                              value: category.value,
                              child: Row(
                                children: [
                                  Icon(
                                    _getIconForCategory(category.value.title),
                                    color: category.value.color, 
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded( 
                                    child: Text(
                                      category.value.title,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSending ? null : _resetForm,
                      child: const Text('Reset', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isSending ? null : _saveItem,
                      icon: _isSending 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                          : const Icon(Icons.add),
                      label: Text(_isSending ? 'Saving...' : 'Add Item'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}