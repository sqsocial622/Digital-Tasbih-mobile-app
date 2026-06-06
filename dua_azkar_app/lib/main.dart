import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const DuaAzkarApp());
}

class DuaAzkarApp extends StatelessWidget {
  const DuaAzkarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dua & Azkar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00838F)),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}
