import 'package:flutter/material.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/screens/teacher/schedule_view.dart';
import 'package:frontend/screens/teacher/student_view.dart';
import 'package:frontend/screens/teacher/mock_exam_view.dart';
import 'package:frontend/screens/teacher/reports_view.dart';
import 'package:frontend/screens/teacher/fees_view.dart';
import 'package:frontend/screens/teacher/courses_view.dart';
import 'package:frontend/services/auth_service.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({Key? key}) : super(key: key);

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // Load user data from SharedPreferences
  Future<void> _loadUser() async {
    final user = await AuthService.getUserFromSharedPreferences();
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Teacher Dashboard",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.white,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black87),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ),
        drawer: SafeArea(
          child: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // User Profile Section
                UserAccountsDrawerHeader(
                  accountName: Text(
                    _user?.fname ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  accountEmail: Text(_user?.email ?? ''),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.blue,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                  ),
                ),
                // Navigation Items
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Schedule'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ScheduleView()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.quiz),
                  title: const Text('Mock Exams'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MockExamView()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Students'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StudentView()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.analytics),
                  title: const Text('Reports'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ReportsView()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.payments),
                  title: const Text('Fees'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FeesView()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.book),
                  title: const Text('Courses'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CoursesView()),
                    );
                  },
                ),
                const Divider(),
                // Settings and Logout
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to settings
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
                              content: const Text(
                                  'Are you sure you want to LogOut ?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Navigate to login
                                  },
                                  child: const Text('Cancel',
                                      style: TextStyle(color: Colors.black)),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (mounted) {
                                      Navigator.pop(
                                          context); // Close the dialog
                                    }
                                    await AuthService.logout();

                                    Navigator.pushReplacementNamed(
                                        context, '/login'); // Navigate to login
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person,
                            size: 35, color: Colors.blue[700]),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome back,',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _user?.fname ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Actions
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildActionCard(
                      icon: Icons.calendar_today,
                      title: 'Schedule',
                      color: Colors.blue[100]!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ScheduleView()),
                        );
                      },
                    ),
                    _buildActionCard(
                      icon: Icons.quiz,
                      title: 'Mock Exam',
                      color: Colors.green[100]!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MockExamView()),
                        );
                      },
                    ),
                    _buildActionCard(
                      icon: Icons.people,
                      title: 'Students',
                      color: Colors.orange[100]!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const StudentView()),
                        );
                      },
                    ),
                    _buildActionCard(
                      icon: Icons.analytics,
                      title: 'Reports',
                      color: Colors.purple[100]!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ReportsView()),
                        );
                      },
                    ),
                    _buildActionCard(
                      icon: Icons.payments,
                      title: 'Fees',
                      color: Colors.red[100]!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FeesView()),
                        );
                      },
                    ),
                    _buildActionCard(
                      icon: Icons.book,
                      title: 'Courses',
                      color: Colors.teal[100]!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CoursesView()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Upcoming Classes
                const Text(
                  'Upcoming Classes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildUpcomingClassCard(
                  subject: 'Korean Language',
                  time: '10:00 AM - 11:30 AM',
                  students: 15,
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildUpcomingClassCard(
                  subject: 'Korean Essentials',
                  time: '2:00 PM - 3:30 PM',
                  students: 12,
                  onTap: () {},
                ),
                const SizedBox(height: 24),

                // Recent Activities
                const Text(
                  'Recent Activities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildActivityCard(
                  title: 'New Assignment Submitted',
                  subtitle: '5 students submitted Korean Writing Assignment',
                  time: '2 hours ago',
                  icon: Icons.assignment_turned_in,
                ),
                const SizedBox(height: 12),
                _buildActivityCard(
                  title: 'Class Attendance Updated',
                  subtitle: 'Updated attendance for Korean Language class',
                  time: '4 hours ago',
                  icon: Icons.check_circle,
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.black87),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingClassCard({
    required String subject,
    required String time,
    required int students,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.class_, color: Colors.blue[700]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$students students',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue[700]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
