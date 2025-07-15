import 'dart:convert';
import 'package:frontend/models/schedule_model.dart';
import 'package:frontend/services/base_url.dart';
import 'package:http/http.dart' as http;

class ScheduleService {
  // Create a new schedule
  static Future<bool> createSchedule(ScheduleModel schedule) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/create-schedule'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(schedule.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print(
            'Failed to create schedule: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating schedule: $e');
      return false;
    }
  }

  // Fetch all schedules
  static Future<List<ScheduleModel>> fetchAllSchedules() async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/get-schedules'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((schedule) => ScheduleModel.fromJson(schedule))
            .toList();
      } else if (response.statusCode == 404) {
        print('No schedules found');
        return []; // No schedules found
      } else {
        throw Exception('Failed to load schedules: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching schedules: $e');
      throw Exception('Failed to load schedules');
    }
  }

  // Fetch schedules for a specific date range
  static Future<List<ScheduleModel>> fetchSchedulesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/get-schedules-by-date-range'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        }),
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((schedule) => ScheduleModel.fromJson(schedule))
            .toList();
      } else if (response.statusCode == 404) {
        return []; // No schedules found
      } else {
        throw Exception(
            'Failed to load schedules by date range: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching schedules by date range: $e');
      throw Exception('Failed to load schedules by date range');
    }
  }

  // Fetch schedules for a specific course
  static Future<List<ScheduleModel>> fetchSchedulesByCourse(
      String courseId) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/get-schedules-by-course'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'courseId': courseId}),
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((schedule) => ScheduleModel.fromJson(schedule))
            .toList();
      } else if (response.statusCode == 404) {
        return []; // No schedules found
      } else {
        throw Exception(
            'Failed to load schedules by course: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching schedules by course: $e');
      throw Exception('Failed to load schedules by course');
    }
  }

  // Fetch a specific schedule by ID
  static Future<ScheduleModel?> fetchScheduleById(String scheduleId) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/get-schedule-by-id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'scheduleId': scheduleId}),
      );

      if (response.statusCode == 200) {
        return ScheduleModel.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        return null; // Schedule not found
      } else {
        throw Exception('Failed to load schedule: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching schedule by ID: $e');
      throw Exception('Failed to load schedule');
    }
  }

  // Update an existing schedule
  static Future<bool> updateSchedule(ScheduleModel schedule) async {
    try {
      final response = await http.put(
        Uri.parse('$url/api/update-schedule'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(schedule.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print(
            'Failed to update schedule: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating schedule: $e');
      return false;
    }
  }

  // Delete a schedule
  static Future<bool> deleteSchedule(String scheduleId) async {
    try {
      final response = await http.delete(
        Uri.parse('$url/api/delete-schedule'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'scheduleId': scheduleId}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print(
            'Failed to delete schedule: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deleting schedule: $e');
      return false;
    }
  }

  // Get today's schedules
  static Future<List<ScheduleModel>> fetchTodaySchedules() async {
    try {
      final today = DateTime.now();
      final startDate = DateTime(today.year, today.month, today.day);
      final endDate = startDate.add(const Duration(days: 1));

      return await fetchSchedulesByDateRange(startDate, endDate);
    } catch (e) {
      print('Error fetching today\'s schedules: $e');
      throw Exception('Failed to load today\'s schedules');
    }
  }

  // Get upcoming schedules (next 7 days)
  static Future<List<ScheduleModel>> fetchUpcomingSchedules() async {
    try {
      final today = DateTime.now();
      final startDate = DateTime(today.year, today.month, today.day);
      final endDate = startDate.add(const Duration(days: 7));

      return await fetchSchedulesByDateRange(startDate, endDate);
    } catch (e) {
      print('Error fetching upcoming schedules: $e');
      throw Exception('Failed to load upcoming schedules');
    }
  }

  // Check for schedule conflicts
  static Future<bool> checkScheduleConflict(
    DateTime date,
    String time,
    String? excludeScheduleId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/check-schedule-conflict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'date': date.toIso8601String().split('T')[0],
          'time': time,
          if (excludeScheduleId != null) 'excludeScheduleId': excludeScheduleId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['hasConflict'] ?? false;
      } else {
        print('Failed to check schedule conflict: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error checking schedule conflict: $e');
      return false;
    }
  }

  // Get student schedules (for enrolled courses)
  static Future<List<ScheduleModel>> fetchStudentSchedules(
      String studentId) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/get-student-schedules'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'studentId': studentId}),
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((schedule) => ScheduleModel.fromJson(schedule))
            .toList();
      } else if (response.statusCode == 404) {
        return []; // No schedules found
      } else {
        throw Exception(
            'Failed to load student schedules: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching student schedules: $e');
      throw Exception('Failed to load student schedules');
    }
  }

  // Update student attendance for a schedule
  static Future<bool> updateStudentAttendance(
    String scheduleId,
    String studentId,
    bool isPresent,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/update-attendance'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'scheduleId': scheduleId,
          'studentId': studentId,
          'isPresent': isPresent,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print(
            'Failed to update attendance: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating attendance: $e');
      return false;
    }
  }

  // Get attendance for a specific schedule
  static Future<Map<String, bool>> getScheduleAttendance(
      String scheduleId) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/get-schedule-attendance'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'scheduleId': scheduleId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Map<String, bool> attendance = {};
        data.forEach((key, value) {
          attendance[key] = value as bool;
        });
        return attendance;
      } else {
        throw Exception('Failed to load attendance: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching attendance: $e');
      throw Exception('Failed to load attendance');
    }
  }
}
