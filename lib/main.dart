import 'package:flutter/material.dart';
import 'package:flutter_mlkit_video/view/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Google MLKit Demo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const MainScreen(),
    );
  }
}
