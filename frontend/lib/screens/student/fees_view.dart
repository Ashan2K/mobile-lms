import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/models/enrollment_model.dart';
import 'package:frontend/models/course_model.dart';
import 'package:frontend/services/course_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeesView extends StatefulWidget {
  const FeesView({Key? key}) : super(key: key);

  @override
  State<FeesView> createState() => _FeesViewState();
}

class _FeesViewState extends State<FeesView> {
  UserModel? _profile;
  String? qrCodeBase64;
  List<EnrollmentModel> _enrollments = [];
  Map<String, CourseModel> _courses = {};
  List<List<String>> _paymentHistory = [];

  // Helper function to format Firebase timestamp to dd/mm/yyyy
  String formatFirebaseTimestamp(dynamic timestamp) {
    DateTime date;
    if (timestamp is String) {
      // ISO8601 string
      date = DateTime.parse(timestamp);
    } else if (timestamp is Map && timestamp.containsKey('_seconds')) {
      // Firestore Timestamp map
      date = DateTime.fromMillisecondsSinceEpoch(timestamp['_seconds'] * 1000);
    } else if (timestamp is int) {
      // Milliseconds since epoch
      date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else {
      return '';
    }
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Future<UserModel?> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String userJson = prefs.getString("user") ?? "{}";
    if (userJson != null) {
      Map<String, dynamic> userMap = json.decode(userJson);
      UserModel user = UserModel.fromJson(userMap);
      debugPrint(user.qrCode);
      return user;
    } else {
      // If no token or user data is found, return null
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile().then((profile) {
      if (!mounted) return;
      setState(() {
        _profile = profile;
      });
      if (profile != null) {
        _loadQRCode();
        _fetchEnrollmentsAndCourses();
        _fetchPaymentHistory();
      }
    });
  }

  Future<void> _loadQRCode() async {
    // Replace with the actual Base64 string you received from the backend
    qrCodeBase64 = _profile!.qrCode; // Your base64 string here

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _fetchEnrollmentsAndCourses() async {
    if (_profile == null) return;
    final userId = _profile!.id;
    final result = await CourseService.fetchEnrollmentsAndCourses(userId);
    if (!mounted) return;
    setState(() {
      _enrollments = (result['enrollments'] as List<EnrollmentModel>);
      _courses = (result['courses'] as Map<String, CourseModel>);
    });
  }

  Future<void> _fetchCoursesForEnrollments() async {
    final courseIds = _enrollments.map((e) => e.courseId).toSet();
    Map<String, CourseModel> courseMap = {};
    for (final courseId in courseIds) {
      final course = await CourseService().fetchCourseDetails(courseId);
      if (course != null) {
        courseMap[courseId] = course;
      }
    }
    if (!mounted) return;
    setState(() {
      _courses = courseMap;
    });
  }

  Future<void> _fetchPaymentHistory() async {
    if (_profile == null) return;
    final userId = _profile!.id;
    final history = await CourseService.fetchPaymentHistory(userId);
    if (!mounted) return;
    setState(() {
      _paymentHistory = history
          .map<List<String>>((item) => [
                item['courseId']?.toString() ?? '',
                item['paidAt'] != null
                    ? formatFirebaseTimestamp(item['paidAt'])
                    : '',
                item['month']?.toString() ?? '',
              ])
          .toList();
    });
  }

  List<List<dynamic>> getDuePaymentRows() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    List<List<dynamic>> rows = [];
    for (var enrollment in _enrollments) {
      DateTime enrolledAt = enrollment.enrolledAt ??
          DateTime(now.year, now.month, 1).subtract(Duration(days: 365));
      // If you add enrolledAt to EnrollmentModel, parse it here.
      int year = enrolledAt.year;
      int month = enrolledAt.month;
      while (DateTime(year, month).isBefore(currentMonth) ||
          DateTime(year, month).isAtSameMomentAs(currentMonth)) {
        String monthStr = "$year-${month.toString().padLeft(2, '0')}";
        print('Checking $monthStr against paid:  ${enrollment.paidMonths}');
        if (!enrollment.paidMonths.contains(monthStr)) {
          final course = _courses[enrollment.courseId];
          rows.add([
            course?.courseName ?? enrollment.courseId,
            course?.courseCode ?? '',
            monthStr,
            true,
          ]);
        }
        month++;
        if (month > 12) {
          month = 1;
          year++;
        }
      }
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fees',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Use this QR code to enter the\nPhysical class',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: qrCodeBase64 == null
                          ? const CircularProgressIndicator()
                          : _buildQRCodeImage(qrCodeBase64!),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download),
                      label: const Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Due payment',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 16),
              _buildPaymentTable(getDuePaymentRows()),
              const SizedBox(height: 32),
              const Text(
                'Payment History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 16),
              _buildPaymentHistoryTable(_paymentHistory),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentTable(List<List<dynamic>> rows) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth, // Fit table to screen
            child: Column(
              children: [
                // Header
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F2F5),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    children: const [
                      SizedBox(width: 8),
                      Expanded(
                        flex: 5,
                        child: Text(
                          'Course',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF222B45),
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Month',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF222B45),
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Action',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF222B45),
                            fontSize: 15,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                // Rows
                ...rows.asMap().entries.map((entry) {
                  int idx = entry.key;
                  List<dynamic> row = entry.value;
                  return _buildPaymentRow(row, idx % 2 == 0);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentHistoryTable(List<List<String>> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0F2F5),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: const [
                SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: Text(
                    'Course',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222B45),
                      fontSize: 17,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Paid At',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222B45),
                      fontSize: 17,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Month',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222B45),
                      fontSize: 17,
                    ),
                  ),
                ),
                SizedBox(width: 8),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          // Rows
          ...rows.asMap().entries.map((entry) {
            int idx = entry.key;
            List<String> row = entry.value;
            return _buildHistoryRow(row, idx % 2 == 0);
          }),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(List<String> rowData, bool isEvenRow) {
    final courseId = rowData[0];
    final paidAt = rowData[1];
    final month = rowData[2];
    final courseName = _courses[courseId]?.courseName ?? courseId;
    return Container(
      decoration: BoxDecoration(
        color: isEvenRow ? const Color(0xFFF7F9FC) : Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: Text(
                courseName,
                style: const TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                paidAt,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 15,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                month,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 15,
                ),
              ),
            ),
            SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(List<dynamic> rowData, bool isEvenRow) {
    final courseName = rowData[0];
    // final courseCode = rowData[1]; // Removed
    final monthStr = rowData[2];
    final isDue = rowData[3];
    final course = _courses.values.firstWhere(
      (c) => c.courseName == courseName, // Removed code check
      orElse: () => _courses.values.first,
    );
    final enrollment = _enrollments.firstWhere(
      (e) => e.courseId == course.courseId,
      orElse: () => _enrollments.first,
    );
    return Container(
      decoration: BoxDecoration(
        color: isEvenRow ? const Color(0xFFF7F9FC) : Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            SizedBox(width: 8),
            Expanded(
              flex: 5,
              child: Text(
                courseName,
                style: const TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                monthStr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 15,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_profile == null) return;
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            const Center(child: CircularProgressIndicator()),
                      );
                      bool success = await CourseService.payMonthlyFee(
                        enrollment.courseId,
                        _profile!.id,
                        course.price,
                        monthStr,
                      );
                      if (!mounted) return;
                      Navigator.of(context).pop(); // Remove loading
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? 'Payment successful!'
                              : 'Payment failed.'),
                        ),
                      );
                      if (success) {
                        await _fetchEnrollmentsAndCourses();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      minimumSize: const Size(60, 36),
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                    child: const Text('Pay', overflow: TextOverflow.ellipsis),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodeImage(String base64String) {
    final String base64Data = base64String.split(',').last;
    final Uint8List bytes = base64Decode(base64Data);
    return Image.memory(bytes);
  }
}
