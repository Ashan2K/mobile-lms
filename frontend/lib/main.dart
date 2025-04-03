import 'package:flutter/material.dart';
import 'package:frontend/screens/student/exam/exam_screen.dart';
import 'package:frontend/screens/student/home_screen.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/auth/signup_screen.dart';
import 'package:frontend/screens/teacher/adminexam.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminScreen(quizCategory: 'mok'),
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
