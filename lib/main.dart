import 'package:flutter/material.dart';
import 'package:shopping_list_app/widgets/grocery_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Groceries',
      theme: ThemeData(
        useMaterial3: true,
        
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 162, 210, 255),
          brightness: Brightness.light,
          surface: const Color.fromARGB(255, 252, 252, 252), // พื้นหลังขาวนวลๆ
        ),
        // แต่ง AppBar 
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 189, 224, 254),
          foregroundColor: Color.fromARGB(255, 43, 45, 66),
          centerTitle: true,
          elevation: 0,
        ),
        // แต่งพวก Card หรือ List 
        scaffoldBackgroundColor: const Color.fromARGB(255, 248, 249, 250),
      ),
      home: const GroceryList(),
    );
  }
}