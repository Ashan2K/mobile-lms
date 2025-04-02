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
        setState(() {
          initState();
        });

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.info, color: Colors.blue[700]),
                title: Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to student details page
                },
              ),
              ListTile(
                leading: student['status'] == 'active'
                    ? Icon(Icons.block, color: Colors.red[700])
                    : Icon(Icons.check_circle, color: Colors.green[700]),
                title: Text(student['status'] == 'active'
                    ? 'Block Student'
                    : 'Unblock Student'),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text(student['status'] == 'active'
                                ? 'Blocked'
                                : 'Unblock'),
                            content: Text(student['status'] == 'active'
                                ? 'Are you sure you want to Block this user ?'
                                : 'Are you sure you want to Unblock this user ?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel',
                                    style: TextStyle(color: Colors.black)),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  if (mounted) {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    _blockUnblockUser(student['uid']);
                                  }
                                  setState(() {
                                    _loadStudent();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: student['status'] == 'active'
                                      ? Colors.red[700]
                                      : Colors.green[700],
                                ),
                                child: Text(
                                    student['status'] == 'active'
                                        ? 'Block'
                                        : 'Unblock',
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ),
                            ],
                          ));
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.warning, color: Color.fromARGB(255, 198, 1, 1)),
                title: Text('Remove Restriction'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to edit student page
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
