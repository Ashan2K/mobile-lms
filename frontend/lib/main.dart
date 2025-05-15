import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:frontend/screens/student/home_screen.dart';
import 'package:frontend/screens/teacher/teacher_home_screen.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/auth/signup_screen.dart';
import 'package:frontend/providers/question_bank_provider.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/models/user_role.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling background message: ${message.messageId}");

  // Get current user role
  final user = await AuthService.getUserFromSharedPreferences();
  if (user == null) return;

  // Check if notification is meant for this user's role
  final targetRole = 'UserRole.student';
  if (targetRole != null && targetRole != user.role.toString()) {
    return; // Skip notification if not meant for this role
  }

  // Show local notification
  if (message.notification != null) {
    showNotification(
      title: message.notification!.title,
      body: message.notification!.body,
    );
  }
}

// Show local notification
Future<void> showNotification({String? title, String? body}) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'default_channel',
    'Default Channel',
    channelDescription: 'Default notification channel',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: 'Default_Sound',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize Firebase Messaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
    // Handle notification tap action
    if (response.payload != null) {
      print('Notification payload: ${response.payload}');
    }
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    // Get current user role
    final user = await AuthService.getUserFromSharedPreferences();
    if (user == null) return;

    print(user.role.toString());
    // Check if notification is meant for this user's role
    final targetRole = 'UserRole.student';
    if (targetRole != null && targetRole != user.role.toString()) {
      return; // Skip notification if not meant for this role
    }

    if (message.notification != null) {
      showNotification(
        title: message.notification!.title,
        body: message.notification!.body,
      );
    }
  });

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<UserModel?> checkLoginStatus() async {
    try {
      return await AuthService.getUserFromSharedPreferences();
    } catch (e) {
      print("Error checking login status: $e");
      return null;
    }
  }

  Widget _getHomeScreen(UserModel user) {
    switch (user.role) {
      case UserRole.student:
        return const HomeScreen();
      case UserRole.teacher:
        return const TeacherHomeScreen();
      default:
        return LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuestionBankProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FutureBuilder<UserModel?>(
          future: checkLoginStatus(),
          builder: (context, snapshot) {
            // Show loading indicator only while checking login status
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Handle error case
            if (snapshot.hasError) {
              print("Error in login check: ${snapshot.error}");
              return LoginScreen();
            }

            // If no data or user is null, show login screen
            if (!snapshot.hasData || snapshot.data == null) {
              return LoginScreen();
            }

            // If we have a valid user, show appropriate home screen
            return _getHomeScreen(snapshot.data!);
          },
        ),
        routes: {
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/home': (context) => const HomeScreen(),
          '/teacher-home': (context) => const TeacherHomeScreen(),
        },
      ),
    );
  }
}
