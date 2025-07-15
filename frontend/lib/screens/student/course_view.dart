import 'package:flutter/material.dart';
import 'package:frontend/models/course_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/course_service.dart';

class CourseView extends StatefulWidget {
  const CourseView({super.key});

  @override
  State<CourseView> createState() => _CourseViewState();
}

class _CourseViewState extends State<CourseView>
    with SingleTickerProviderStateMixin {
  late Future<List<CourseModel>> _coursesFuture;
  late Future<List<CourseModel>> _enrolledCoursesFuture;
  late TabController _tabController;

  // Store enrolled course IDs for filtering
  List<String> _enrolledCourseIds = [];

  @override
  void initState() {
    super.initState();
    _coursesFuture = CourseService.fetchCourses();
    _tabController = TabController(length: 2, vsync: this);
    _enrolledCoursesFuture = Future.value([]);

    _loadEnrolledCourses();
  }

  void _loadEnrolledCourses() async {
    final user = await AuthService.getCurrentUser();
    print("Current User: ${user?.id}");
    if (user != null) {
      final enrolledCourses = await CourseService.fetchEnrolledCourses(user.id);
      print("Enrolled Courses: ${enrolledCourses.length}");
      if (!mounted) return;
      setState(() {
        _enrolledCoursesFuture = Future.value(enrolledCourses);
        _enrolledCourseIds =
            enrolledCourses.map((c) => c.courseId ?? '').toList();
        print("Enrolled Course IDs: $_enrolledCourseIds");
      });
    } else {
      setState(() {
        _enrolledCoursesFuture = Future.value([]);
        _enrolledCourseIds = [];
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Courses",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () {
              Navigator.pop(context);
            }),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Course'),
            Tab(text: 'My Course'),
          ],
          labelColor: Colors.black87,
          indicatorColor: Colors.blue,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: All Courses
          FutureBuilder<List<List<CourseModel>>>(
            future: Future.wait([_coursesFuture, _enrolledCoursesFuture]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error:  ${snapshot.error}'));
              }
              if (!snapshot.hasData ||
                  snapshot.data == null ||
                  snapshot.data!.isEmpty ||
                  snapshot.data![0].isEmpty) {
                return const Center(child: Text('No courses found.'));
              }

              final List<CourseModel> allCourses = snapshot.data![0];
              final List<CourseModel> enrolledCourses = snapshot.data![1];
              final Set<String> enrolledIds =
                  enrolledCourses.map((c) => c.courseId ?? '').toSet();
              final List<CourseModel> notEnrolledCourses = allCourses
                  .where((c) => !enrolledIds.contains(c.courseId))
                  .toList();
              //print notEnrolledCourses items
              print("Not Enrolled Courses: ${notEnrolledCourses.length}");

              if (notEnrolledCourses.isEmpty) {
                return const Center(
                    child: Text('No available courses to enroll.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: notEnrolledCourses.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildCourseCard(notEnrolledCourses[index],
                        enrolled: false),
                  );
                },
              );
            },
          ),
          // Tab 2: My Course (Enrolled Courses)
          FutureBuilder<List<CourseModel>>(
            future: _enrolledCoursesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error:  ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No enrolled courses found.'));
              }

              final courses = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildCourseCard(courses[index], enrolled: true),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Builds the course card using only the required frontend fields.
  Widget _buildCourseCard(CourseModel course, {bool enrolled = false}) {
    final color = course.status == "Upcoming" ? Colors.blue : Colors.green;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Course Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        course.status.toUpperCase(),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    // Course Code Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        course.courseCode,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Course Name
                Text(
                  course.courseName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Course Description
                Text(
                  course.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey[200], height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(Icons.calendar_today, 'Start Date',
                    course.startDate.toLocal().toString().split(' ')[0]),
                const SizedBox(height: 10),
                _buildInfoRow(Icons.access_time, 'Schedule',
                    course.schedule.split(' ').last),
                const SizedBox(height: 10),
                _buildInfoRow(Icons.price_change_outlined, 'Price',
                    'LKR ${course.price}'),
                const SizedBox(height: 20),
                if (!enrolled)
                  ElevatedButton(
                    onPressed: () {
                      _showStripeEnrollDialog(context, course);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Enroll with Stripe',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                if (enrolled)
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement navigation to course details or materials
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('View Course pressed.')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'View Course',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper widget to build consistent info rows.
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[500]),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showStripeEnrollDialog(BuildContext context, CourseModel course) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enroll in Course'),
        content: Text('Proceed to pay and enroll in "${course.courseName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final currentUser = await AuthService.getCurrentUser();
              if (!mounted) return;
              if (currentUser != null) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );
                bool success = await CourseService.enrollInCourseWithStripe(
                  course.price,
                  course.courseId!,
                  currentUser.id,
                );
                if (!mounted) return;
                Navigator.of(context).pop(); // Remove loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Enrolled successfully with Stripe!'
                        : 'Stripe payment or enrollment failed.'),
                  ),
                );
                if (success) {
                  _loadEnrolledCourses(); // Refresh enrolled courses
                }
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please log in to enroll.')),
                );
              }
            },
            child: const Text('Pay & Enroll'),
          ),
        ],
      ),
    );
  }
}
