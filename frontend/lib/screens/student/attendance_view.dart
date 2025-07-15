import 'package:flutter/material.dart';
import 'package:frontend/models/course_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/course_service.dart';
import 'package:frontend/services/attendance_service.dart';

class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  UserModel? _currentUser;
  List<CourseModel> _enrolledCourses = [];
  Map<String, List<Map<String, dynamic>>> _attendanceData = {};
  bool _isLoading = true;
  String? _error;
  String searchQuery = '';
  Map<String, String> statusFilters = {};
  List<String> expandedModules = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get current user
      final user = await AuthService.getCurrentUser();
      if (user == null) {
        throw Exception('User not found. Please login again.');
      }

      // Fetch enrolled courses
      final enrolledCourses = await CourseService.fetchEnrolledCourses(user.id);
      print('Fetched ${enrolledCourses.length} enrolled courses');
      if (enrolledCourses.isEmpty) {
        throw Exception(
            'No enrolled courses found. Please enroll in a course first.');
      }

      // Fetch attendance data for each course
      Map<String, List<Map<String, dynamic>>> attendanceData = {};

      for (final course in enrolledCourses) {
        if (course.courseId != null) {
          print(
              'Fetching attendance for course: ${course.courseName} (${course.courseId})');
          final attendanceHistory =
              await AttendanceService.getAttendanceHistory(
            user.id,
            course.courseId!,
          );

          print(
              'Found ${attendanceHistory.length} attendance records for ${course.courseName}');

          // Transform the attendance data to match the expected format
          final transformedData = attendanceHistory.map((record) {
            return {
              'date': record['date'] ?? '',
              'hours': record['hours']?.toString() ?? '0',
              'status': record['status'] ?? 'Unknown',
            };
          }).toList();

          attendanceData[course.courseName] = transformedData;
        }
      }

      // Check if we have any attendance data
      if (attendanceData.isEmpty) {
        throw Exception(
            'No attendance records found for your enrolled courses.');
      }

      if (mounted) {
        setState(() {
          _currentUser = user;
          _enrolledCourses = enrolledCourses;
          _attendanceData = attendanceData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load attendance data: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading attendance data...'),
              ],
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final modules = _attendanceData.keys.toList();
    final filteredModules = modules
        .where((module) =>
            module.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Text(
                'Attendance',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Material(
                elevation: 1,
                borderRadius: BorderRadius.circular(24),
                child: TextField(
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: 'Search courses...',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: filteredModules.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school_outlined,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No courses found.',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: filteredModules.length,
                        itemBuilder: (context, idx) {
                          final module = filteredModules[idx];
                          final data = _attendanceData[module]!;
                          final statusFilter = statusFilters[module] ?? 'All';
                          final filteredData = statusFilter == 'All'
                              ? data
                              : data
                                  .where((record) =>
                                      record['status'] == statusFilter)
                                  .toList();
                          final totalClasses = data.length;
                          final presentClasses = data
                              .where((record) => record['status'] == 'present')
                              .length;
                          final attendancePercentage = totalClasses == 0
                              ? '0.0'
                              : (presentClasses / totalClasses * 100)
                                  .toStringAsFixed(1);
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent,
                                splashColor: Colors.blue[50],
                              ),
                              child: ExpansionTile(
                                key: PageStorageKey(module),
                                initiallyExpanded:
                                    expandedModules.contains(module),
                                onExpansionChanged: (expanded) {
                                  setState(() {
                                    if (expanded) {
                                      expandedModules.add(module);
                                    } else {
                                      expandedModules.remove(module);
                                    }
                                  });
                                },
                                tilePadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        module,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFF1E1E1E),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[700],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '$presentClasses/$totalClasses',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '(${attendancePercentage}%)',
                                      style: const TextStyle(
                                        color: Color(0xFF4788A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 4),
                                    child: Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: [
                                        const Text('Filter by status:'),
                                        FilterChip(
                                          label: const Text('All'),
                                          selected: statusFilter == 'All',
                                          selectedColor: Colors.blue[100],
                                          onSelected: (_) {
                                            setState(() {
                                              statusFilters[module] = 'All';
                                            });
                                          },
                                        ),
                                        FilterChip(
                                          label: const Text('present'),
                                          selected: statusFilter == 'present',
                                          selectedColor: Colors.green[100],
                                          onSelected: (_) {
                                            setState(() {
                                              statusFilters[module] = 'present';
                                            });
                                          },
                                        ),
                                        FilterChip(
                                          label: const Text('Absent'),
                                          selected: statusFilter == 'Absent',
                                          selectedColor: Colors.red[100],
                                          onSelected: (_) {
                                            setState(() {
                                              statusFilters[module] = 'Absent';
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildAttendanceTable(filteredData),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceTable(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No attendance records found for this course.'),
      );
    }
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(
          Colors.blue[50],
        ),
        columns: const [
          DataColumn(
            label: Text(
              'Date',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
            ),
          ),
          DataColumn(
            label: Text(
              'Status',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
            ),
          ),
        ],
        rows: data.map((record) {
          return DataRow(
            color: MaterialStateProperty.all(
              record['status'] == 'present' ? Colors.green[50] : Colors.red[50],
            ),
            cells: [
              DataCell(Text(record['date'],
                  style: const TextStyle(color: Color(0xFF1E1E1E)))),
              DataCell(
                Chip(
                  label: Text(
                    record['status'],
                    style: TextStyle(
                      color: record['status'] == 'present'
                          ? Colors.green[800]
                          : Colors.red[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: record['status'] == 'present'
                      ? Colors.green[100]
                      : Colors.red[100],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
