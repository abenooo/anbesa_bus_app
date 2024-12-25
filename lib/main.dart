import 'package:flutter/material.dart';
import 'package:anbessa_bus_app/screens/home_screen.dart';

void main() {
  runApp(const AnbessaBusApp());
}

class AnbessaBusApp extends StatelessWidget {
  const AnbessaBusApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anbessa Bus App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}

