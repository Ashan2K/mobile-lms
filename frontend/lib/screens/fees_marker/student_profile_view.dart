import 'package:flutter/material.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/models/course_model.dart';
import 'package:frontend/services/student_service.dart';
import 'package:frontend/services/course_service.dart';
import 'package:frontend/services/attendance_service.dart';
import 'package:intl/intl.dart';

class StudentProfileView extends StatefulWidget {
  final String studentId;
  final CourseModel selectedCourse;

  const StudentProfileView({
    Key? key,
    required this.studentId,
    required this.selectedCourse,
  }) : super(key: key);

  @override
  State<StudentProfileView> createState() => _StudentProfileViewState();
}

class _StudentProfileViewState extends State<StudentProfileView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserModel? _student;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _attendanceHistory = [];
  List<Map<String, dynamic>> _paymentHistory = [];
  bool _isMarkingAttendance = false;
  bool _isRecordingPayment = false;
  List<String> _duePayments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStudentData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load student details
      final student = await StudentService.getStudentById(widget.studentId);

      // Load attendance and payment history
      final attendanceHistory = await AttendanceService.getAttendanceHistory(
        widget.studentId,
        widget.selectedCourse.courseId!,
      );

      final duePayments = await CourseService.getCourseDuePayments(
        widget.studentId,
        widget.selectedCourse.courseId!,
      );

      final paymentHistory = await StudentService.getPaymentHistory(
        widget.studentId,
        widget.selectedCourse.courseId!,
      );

      if (mounted) {
        setState(() {
          _student = student;
          _attendanceHistory = attendanceHistory;
          _paymentHistory = paymentHistory;
          _duePayments = duePayments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load student data: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAttendance() async {
    if (_isMarkingAttendance) return;

    setState(() {
      _isMarkingAttendance = true;
    });

    try {
      final success = await AttendanceService.markAttendance(
        widget.studentId,
        widget.selectedCourse.courseId!,
      );

      if (success) {
        // Reload attendance history
        final attendanceHistory = await AttendanceService.getAttendanceHistory(
          widget.studentId,
          widget.selectedCourse.courseId!,
        );

        if (mounted) {
          setState(() {
            _attendanceHistory = attendanceHistory;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance marked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to mark attendance'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error marking attendance: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isMarkingAttendance = false;
        });
      }
    }
  }

  Future<void> _recordPayment() async {
    if (_isRecordingPayment) return;

    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Payment'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (Rs.)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                await _processPayment(double.parse(amountController.text));
              }
            },
            child: const Text('Record'),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment(double amount) async {
    setState(() {
      _isRecordingPayment = true;
    });

    try {
      final success = await StudentService.recordFeePayment(
        widget.studentId,
        widget.selectedCourse.courseId!,
        amount,
      );

      if (success) {
        // Reload payment history
        final paymentHistory = await StudentService.getPaymentHistory(
          widget.studentId,
          widget.selectedCourse.courseId!,
        );

        if (mounted) {
          setState(() {
            _paymentHistory = paymentHistory;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Payment of Rs. ${amount.toStringAsFixed(2)} recorded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to record payment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error recording payment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRecordingPayment = false;
        });
      }
    }
  }

  Future<void> _payDueMonth(String month) async {
    final amount = widget.selectedCourse.price;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Payment'),
        content: Text(
            'Pay Rs. ${amount.toStringAsFixed(2)} for ${_formatMonth(month)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Pay'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Processing payment...')),
    );
    final success = await CourseService.payMonthlyFee(
      widget.selectedCourse.courseId!,
      widget.studentId,
      amount,
      month,
    );
    if (success) {
      await _loadStudentData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Payment for ${_formatMonth(month)} successful!'),
            backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Payment failed for ${_formatMonth(month)}'),
            backgroundColor: Colors.red),
      );
    }
  }

  // Helper to format month string (e.g., '2025-07' -> 'July 2025')
  String _formatMonth(String month) {
    try {
      final parts = month.split('-');
      if (parts.length == 2) {
        final year = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final date = DateTime(year, m);
        return DateFormat('MMMM yyyy').format(date);
      }
    } catch (_) {}
    return month;
  }

  // Helper to format paidAt (Firestore timestamp or ISO string)
  String _formatPaidAt(dynamic paidAt) {
    DateTime? date;
    if (paidAt is Map && paidAt.containsKey('_seconds')) {
      date = DateTime.fromMillisecondsSinceEpoch(paidAt['_seconds'] * 1000);
    } else if (paidAt is String) {
      date = DateTime.tryParse(paidAt);
    }
    if (date != null) {
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadStudentData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(_error!, style: TextStyle(color: Colors.red[700])),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadStudentData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _student == null
                  ? const Center(child: Text('Student not found'))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Student Profile Header
                          Card(
                            elevation: 4,
                            margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 28, horizontal: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Profile Image
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.15),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 48,
                                      backgroundColor: Colors.blue[50],
                                      backgroundImage: _student!.imageUrl !=
                                              null
                                          ? NetworkImage(_student!.imageUrl!)
                                          : null,
                                      child: _student!.imageUrl == null
                                          ? Text(
                                              _getInitials(),
                                              style: TextStyle(
                                                fontSize: 32,
                                                color: Colors.blue[700],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  // Name
                                  Text(
                                    '${_student!.fname} ${_student!.lname}',
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // ID
                                  Text(
                                    _student!.stdId ?? 'No ID',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Status
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _student!.status == 'active'
                                          ? Colors.green[100]
                                          : Colors.red[100],
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _student!.status == 'active'
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color: _student!.status == 'active'
                                              ? Colors.green[700]
                                              : Colors.red[700],
                                          size: 18,
                                        ),
                                        const SizedBox(width: 7),
                                        Text(
                                          _student!.status ?? 'Unknown',
                                          style: TextStyle(
                                            color: _student!.status == 'active'
                                                ? Colors.green[700]
                                                : Colors.red[700],
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Course Info
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.school, color: Colors.blue[700]),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.selectedCourse.courseName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                      Text(
                                        widget.selectedCourse.courseCode,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Due Payments Section
                          if (_duePayments.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.red[50],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                                Icons.warning_amber_rounded,
                                                color: Colors.red,
                                                size: 28),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Due Payments',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      ..._duePayments.map((month) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange[50],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: const Icon(
                                                      Icons.calendar_month,
                                                      color: Colors.orange,
                                                      size: 22),
                                                ),
                                                const SizedBox(width: 14),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        _formatMonth(month),
                                                        style: const TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                Colors.black87),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        'Rs. ${widget.selectedCourse.price.toStringAsFixed(2)}',
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.red),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.red[400],
                                                    foregroundColor:
                                                        Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 18,
                                                        vertical: 10),
                                                  ),
                                                  onPressed: () =>
                                                      _payDueMonth(month),
                                                  child: const Text('Pay'),
                                                ),
                                              ],
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          // Action Buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isMarkingAttendance
                                        ? null
                                        : _markAttendance,
                                    icon: _isMarkingAttendance
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          )
                                        : const Icon(
                                            Icons.check_circle_outline),
                                    label: Text(_isMarkingAttendance
                                        ? 'Marking...'
                                        : 'Mark Attendance'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[600],
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isRecordingPayment
                                        ? null
                                        : _onNextScanPressed,
                                    icon: _isRecordingPayment
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          )
                                        : const Icon(Icons.qr_code_scanner),
                                    label: Text(_isRecordingPayment
                                        ? 'Loading...'
                                        : 'Next Scan'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple[600],
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Tab Bar
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              isScrollable: false,
                              indicatorColor: Colors.blue[700],
                              indicatorWeight: 3.5,
                              labelColor: Colors.blue[700],
                              unselectedLabelColor: Colors.grey[600],
                              labelStyle: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15),
                              unselectedLabelStyle: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 15),
                              tabs: const [
                                Tab(text: 'Profile'),
                                Tab(text: 'Attendance'),
                                Tab(text: 'Payments'),
                              ],
                            ),
                          ),

                          // Tab Content
                          SizedBox(
                            height: 500,
                            child: TabBarView(
                              controller: _tabController,
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                _buildProfileTab(),
                                _buildAttendanceTab(),
                                _buildPaymentsTab(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            'Personal Information',
            [
              _buildInfoRow(Icons.email_outlined, 'Email', _student!.email),
              _buildInfoRow(Icons.phone_outlined, 'Phone',
                  _student!.phoneNumber ?? 'Not provided'),
              _buildInfoRow(
                  Icons.qr_code, 'QR Code', _student!.qrCode ?? 'Not provided'),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            'Course Information',
            [
              _buildInfoRow(
                  Icons.school, 'Course', widget.selectedCourse.courseName),
              _buildInfoRow(
                  Icons.code, 'Course Code', widget.selectedCourse.courseCode),
              _buildInfoRow(Icons.attach_money, 'Course Fee',
                  'Rs. ${widget.selectedCourse.price.toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab() {
    return _attendanceHistory.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_note, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No attendance records found',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _attendanceHistory.length,
            itemBuilder: (context, index) {
              final record = _attendanceHistory[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.check_circle,
                    color: Colors.green[600],
                  ),
                  title: Text('Attendance Record'),
                  subtitle: Text(
                    'Date: ${record['date'] ?? 'Unknown'}',
                  ),
                  trailing: Text(
                    record['status'] ?? 'Present',
                    style: TextStyle(
                      color: Colors.green[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildPaymentsTab() {
    return _paymentHistory.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payment, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No payment records found',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _paymentHistory.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final record = _paymentHistory[index];
              final amount =
                  double.tryParse(record['amount']?.toString() ?? '') ?? 0.0;
              final month = record['month'] ?? '';
              final paidAt = record['paidAt'];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.payments,
                            color: Colors.blue, size: 28),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rs. ${amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.calendar_month,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  _formatMonth(month),
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black87),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  _formatPaidAt(paidAt),
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials() {
    String firstInitial = _student!.fname.isNotEmpty ? _student!.fname[0] : '';
    String lastInitial = _student!.lname.isNotEmpty ? _student!.lname[0] : '';
    return (firstInitial + lastInitial).toUpperCase();
  }

  // Add the placeholder function for Next Scan
  void _onNextScanPressed() {
    Navigator.of(context).pop();
  }
}
