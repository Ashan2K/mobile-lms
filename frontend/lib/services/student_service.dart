import 'dart:convert';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/services/base_url.dart';
import 'package:http/http.dart' as http;

class StudentService {
  /// Get student details by ID
  static Future<UserModel?> getStudentById(String studentId) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/get-studentById'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': studentId}),
      );

      if (response.statusCode == 200) {
        print('Student details fetched successfully: ${response.body}');
        final data = json.decode(response.body);
        return UserModel.fromJson(data);
      } else if (response.statusCode == 404) {
        return null; // Student not found
      } else {
        throw Exception(
            'Failed to get student details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting student by ID: $e');
      throw Exception('Failed to get student details: $e');
    }
  }

  /// Record fee payment for a student
  static Future<bool> recordFeePayment(
      String studentId, String courseId, double amount) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/record-fee-payment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'studentId': studentId,
          'courseId': courseId,
          'amount': amount,
          'date': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to record fee payment: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error recording fee payment: $e');
      return false;
    }
  }

  /// Get student's payment history for a course
  static Future<List<Map<String, dynamic>>> getPaymentHistory(
      String studentId, String courseId) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/get-course-payment-historyById'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': studentId,
          'courseId': courseId,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting payment history: $e');
      return [];
    }
  }
}
