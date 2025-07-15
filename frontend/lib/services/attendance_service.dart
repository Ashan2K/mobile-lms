import 'package:http/http.dart' as http;
import 'package:frontend/services/base_url.dart';
import 'dart:convert';

class AttendanceService {
  //mark attendance for a student
  static Future<bool> markAttendance(String studentId, String courseId) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/mark-attendance'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'studentId': studentId,
          'courseId': courseId,
          'date': DateTime.now().toIso8601String().split('T')[0],
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to mark attendance: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error marking attendance: $e');
      return false;
    }
  }

  // Get attendance history for a student
  static Future<List<Map<String, dynamic>>> getAttendanceHistory(
      String studentId, String courseId) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/get-attendance-of-user'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'studentId': studentId,
          'courseId': courseId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('Failed to get attendance history: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getting attendance history: $e');
      return [];
    }
  }
}
