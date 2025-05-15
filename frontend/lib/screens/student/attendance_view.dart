import 'package:flutter/material.dart';

class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  String? selectedModule;

  final Map<String, List<Map<String, dynamic>>> moduleAttendanceData = {
    'Course Module 1': [
      {'date': '2025-01-31', 'hours': '4', 'status': 'Absent'},
      {'date': '2025-02-07', 'hours': '2', 'status': 'Present'},
      {'date': '2025-02-21', 'hours': '4', 'status': 'Present'},
      {'date': '2025-03-07', 'hours': '2', 'status': 'Absent'},
    ],
    'Course Module 2': [
      {'date': '2025-02-01', 'hours': '3', 'status': 'Present'},
      {'date': '2025-02-08', 'hours': '3', 'status': 'Present'},
      {'date': '2025-02-15', 'hours': '3', 'status': 'Absent'},
      {'date': '2025-02-22', 'hours': '3', 'status': 'Present'},
      {'date': '2025-03-01', 'hours': '3', 'status': 'Present'},
    ],
    'Course Module 3': [
      {'date': '2025-01-15', 'hours': '2', 'status': 'Present'},
      {'date': '2025-01-22', 'hours': '2', 'status': 'Present'},
      {'date': '2025-01-29', 'hours': '2', 'status': 'Present'},
      {'date': '2025-02-05', 'hours': '2', 'status': 'Absent'},
      {'date': '2025-02-12', 'hours': '2', 'status': 'Present'},
      {'date': '2025-02-19', 'hours': '2', 'status': 'Present'},
    ],
    'Course Module 4': [
      {'date': '2025-02-14', 'hours': '4', 'status': 'Present'},
      {'date': '2025-02-28', 'hours': '4', 'status': 'Absent'},
      {'date': '2025-03-14', 'hours': '4', 'status': 'Present'},
      {'date': '2025-03-28', 'hours': '4', 'status': 'Present'},
      {'date': '2025-04-11', 'hours': '4', 'status': 'Present'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    List<String> modules = [
      'Course Module 1',
      'Course Module 2',
      'Course Module 3',
      'Course Module 4',
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),
              // Module buttons
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: modules
                      .map(
                        (module) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: _buildButton(module),
                        ),
                      )
                      .toList(),
                ),
              ),
              // Attendance table
              if (selectedModule != null) ...[
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        selectedModule!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4788A8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildAttendanceSummary(),
                    ],
                  ),
                ),
                _buildAttendanceTable(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceSummary() {
    if (selectedModule == null) return const SizedBox.shrink();

    final data = moduleAttendanceData[selectedModule]!;
    final totalClasses = data.length;
    final presentClasses =
        data.where((record) => record['status'] == 'Present').length;
    final attendancePercentage =
        (presentClasses / totalClasses * 100).toStringAsFixed(1);

    return Text(
      'Attendance: $presentClasses/$totalClasses ($attendancePercentage%)',
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF4788A8),
      ),
    );
  }

  Widget _buildAttendanceTable() {
    if (selectedModule == null) return const SizedBox.shrink();

    final data = moduleAttendanceData[selectedModule]!;

    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            const Color(0xFF4788A8).withOpacity(0.1),
          ),
          columns: const [
            DataColumn(
              label: Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Hours',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: data.map((record) {
            return DataRow(
              color: MaterialStateProperty.all(
                record['status'] == 'Present'
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
              ),
              cells: [
                DataCell(Text(record['date'])),
                DataCell(Text(record['hours'])),
                DataCell(
                  Text(
                    record['status'],
                    style: TextStyle(
                      color: record['status'] == 'Present'
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildButton(String text) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedModule = text;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 104, 171, 200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 58, 44, 44),
          ),
        ),
      ),
    );
  }
}
