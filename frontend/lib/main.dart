import 'package:flutter/material.dart';
import 'package:frontend/screens/student/home_screen.dart';
import 'package:frontend/screens/student/login_screen.dart';
import 'package:frontend/screens/student/signup_screen.dart';
import 'package:frontend/screens/teacher/teacher_home_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TeacherHomeScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
