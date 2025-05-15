import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/services/student_manage.dart';

class StudentView extends StatefulWidget {
  const StudentView({Key? key}) : super(key: key);

  @override
  State<StudentView> createState() => _StudentViewState();
}

class _StudentViewState extends State<StudentView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<UserModel?>? _students;
  StudentManage studentManage = new StudentManage();

  // Load students from API
  Future<void> _loadStudent() async {
    List<UserModel?>? students = await studentManage.loadStudent();
    debugPrint(students.toString());
    setState(() {
      _students = students;
    });
  }

  // Filter students based on search query
  List<UserModel?> get _filteredStudents {
    if (_searchQuery.isEmpty)
      return _students ?? []; // If search is empty, return all students
    return _students!.where((student) {
      // Filter by first name, last name, or email (or any other property)
      return (student?.fname ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (student?.lname ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (student?.email ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (student?.id ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<bool> _blockUnblockUser(String uid) async {
    try {
      final response = await studentManage.blockUnblockStudent(uid);
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _loadStudent();
          });
        }
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Students",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Student List
          Expanded(
            child: _students == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = _filteredStudents[index];
                      return _buildStudentCard(student!.toMap());
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add student functionality
        },
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showStudentOptionsOverlay(context, student);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Text(
                  student['name'][0],
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      student['stdId'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: student['status'] == 'active'
                      ? Colors.green[100]
                      : student['status'] == 'blocked'
                          ? Colors.red[100]
                          : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  student['status'],
                  style: TextStyle(
                    color: student['status'] == 'active'
                        ? Colors.green[700]
                        : student['status'] == 'blocked'
                            ? Colors.red[700]
                            : Colors.grey[700],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStudentOptionsOverlay(
      BuildContext context, Map<String, dynamic> student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Profile Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Profile Image
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue[100],
                      backgroundImage: student['imageUrl'] != null
                          ? NetworkImage(student['imageUrl'])
                          : null,
                      child: student['imageUrl'] == null
                          ? Text(
                              _getInitials(student),
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    // Name
                    Text(
                      student['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Student ID
                    Text(
                      student['stdId'] ?? 'No ID',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: student['status'] == 'active'
                            ? Colors.green[100]
                            : Colors.red[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        student['status'] ?? 'Unknown',
                        style: TextStyle(
                          color: student['status'] == 'active'
                              ? Colors.green[700]
                              : Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Student Details
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailItem(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        value: student['email'] ?? 'No email',
                      ),
                      _buildDetailItem(
                        icon: Icons.phone_outlined,
                        title: 'Phone',
                        value: student['phoneNumber'] ?? 'No phone',
                      ),
                      _buildDetailItem(
                        icon: Icons.qr_code,
                        title: 'QR Code',
                        value: student['qrCodeUrl'] ?? 'No QR Code',
                        isQR: true,
                      ),
                      _buildDetailItem(
                        icon: Icons.devices,
                        title: 'Device ID',
                        value: student['deviceId'] ?? 'No device ID',
                        isEditable: true,
                        onEdit: () {
                          // TODO: Implement device ID update
                          _showUpdateDeviceIdDialog(context, student);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Action Buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(student['status'] == 'active'
                                  ? 'Block Student'
                                  : 'Unblock Student'),
                              content: Text(
                                student['status'] == 'active'
                                    ? 'Are you sure you want to block this student?'
                                    : 'Are you sure you want to unblock this student?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    Navigator.pop(context); // Close dialog
                                    Navigator.pop(
                                        context); // Close bottom sheet
                                    await _blockUnblockUser(student['uid']);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        student['status'] == 'active'
                                            ? Colors.red[700]
                                            : Colors.green[700],
                                  ),
                                  child: Text(
                                    student['status'] == 'active'
                                        ? 'Block'
                                        : 'Unblock',
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: student['status'] == 'active'
                              ? Colors.red[700]
                              : Colors.green[700],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          student['status'] == 'active'
                              ? 'Block Student'
                              : 'Unblock Student',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement remove restriction
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[700],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Remove Restriction'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    bool isEditable = false,
    bool isQR = false,
    VoidCallback? onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 24,
            color: Colors.blue[700],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isEditable)
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: onEdit,
                        color: Colors.blue[700],
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    if (isQR && value != 'No QR Code')
                      IconButton(
                        icon: const Icon(Icons.qr_code_scanner, size: 20),
                        onPressed: () {
                          // TODO: Implement QR code view/scan
                        },
                        color: Colors.blue[700],
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateDeviceIdDialog(
      BuildContext context, Map<String, dynamic> student) {
    final TextEditingController deviceIdController = TextEditingController(
      text: student['deviceId'],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Device ID'),
        content: TextField(
          controller: deviceIdController,
          decoration: const InputDecoration(
            labelText: 'Device ID',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // TODO: Implement device ID update API call
              Navigator.pop(context);
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Device ID updated successfully'),
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // Helper method to safely get initials
  String _getInitials(Map<String, dynamic> student) {
    String firstInitial =
        (student['fname'] ?? '').isNotEmpty ? student['fname'][0] : '';
    String lastInitial =
        (student['lname'] ?? '').isNotEmpty ? student['lname'][0] : '';
    return (firstInitial + lastInitial).toUpperCase();
  }

  // Helper method to safely get full name
  String _getFullName(Map<String, dynamic> student) {
    String firstName = student['fname'] ?? '';
    String lastName = student['lname'] ?? '';
    if (firstName.isEmpty && lastName.isEmpty) {
      return 'Unknown Student';
    }
    return '${firstName.trim()} ${lastName.trim()}'.trim();
  }
}
