// main.dart
import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/desktophome.dart';
import 'screens/mobilehome.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warning Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/mobilehome': (context) => MobileHomeScreen(),
        '/desktophome': (context) => DesktopHomeScreen(),
      },
    );
  }
}