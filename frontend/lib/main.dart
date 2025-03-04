import 'package:flutter/material.dart';
import 'package:frontend/screen/home_sreen.dart';
import 'package:frontend/screen/login_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
