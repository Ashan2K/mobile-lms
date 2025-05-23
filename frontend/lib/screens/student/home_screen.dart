import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/components/custom_app_bar.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/screens/student/attendance_view.dart';
import 'package:frontend/screens/student/course_view.dart';
import 'package:frontend/screens/student/mark_view.dart';
import 'package:frontend/screens/student/profile_view.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_view.dart';
import 'recordings_view.dart';
import 'fees_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  UserModel? _profile;

  final List<Widget> _screens = [
    const DashboardView(),
    const RecordingsView(),
    const FeesView(),
    const MarkView(),
    const AttendanceView()
  ];

  Future<UserModel?> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String userJson = prefs.getString("user") ?? "{}";
    if (userJson != null) {
      Map<String, dynamic> userMap = json.decode(userJson);
      UserModel user = UserModel.fromJson(userMap);
      print(user.fname);
      return user;
    } else {
      // If no token or user data is found, return null
      return null;
    }
  }

  Future<void> _handleLogout() async {
    try {
      await AuthService.logout();
      if (!mounted) return;

      // Use pushAndRemoveUntil to clear the navigation stack
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during logout: $e')),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    NotificationService.getAndStoreFcmToken();
    _loadProfile().then((profile) {
      setState(() {
        _profile = profile;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue[700],
          unselectedItemColor: Colors.grey[600],
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_library_outlined),
              label: 'Recordings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.payment_outlined),
              label: 'Fees',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grade),
              label: 'Marks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'Attendance',
            ),
          ],
        ),
      ),
      drawer: SafeArea(
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue[700]!,
                      Colors.blue[500]!,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('lib/images/profile.jpeg'),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${_profile?.fname ?? ''} ${_profile?.lname ?? ''}'
                          .trim(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _profile?.stdId ?? '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileView()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.class_outlined),
                title: const Text('Course'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CourseView()));
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Help & Support'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title:
                    const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content:
                                const Text('Are you sure you want to LogOut ?'),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setBool('is_logged_in', false);
                                  Navigator.pop(context); // Navigate to login
                                },
                                child: const Text('Cancel',
                                    style: TextStyle(color: Colors.black)),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (mounted) {
                                    Navigator.pop(context); // Close the dialog
                                  }
                                  _handleLogout();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[700],
                                ),
                                child: const Text('Logout',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateItem(String title) {
    return Row(
      children: [
        Container(
          width: 120,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1E1E1E),
            ),
          ),
        ),
      ],
    );
  }
}
