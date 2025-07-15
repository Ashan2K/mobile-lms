import 'package:flutter/foundation.dart';
import 'package:frontend/models/schedule_model.dart';
import 'package:frontend/services/schedule_service.dart';

class ScheduleProvider extends ChangeNotifier {
  List<ScheduleModel> _schedules = [];
  bool _isLoading = false;
  String? _error;
  Map<DateTime, List<ScheduleModel>> _eventsByDate = {};

  // Getters
  List<ScheduleModel> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<DateTime, List<ScheduleModel>> get eventsByDate => _eventsByDate;

  // Load all schedules
  Future<void> loadAllSchedules() async {
    _setLoading(true);
    _clearError();

    try {
      final schedules = await ScheduleService.fetchAllSchedules();
      _schedules = schedules;
      _organizeSchedulesByDate();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load schedules: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load schedules for a student
  Future<void> loadStudentSchedules(String studentId) async {
    _setLoading(true);
    _clearError();

    try {
      final schedules = await ScheduleService.fetchStudentSchedules(studentId);
      _schedules = schedules;
      _organizeSchedulesByDate();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load schedules: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create a new schedule
  Future<bool> createSchedule(ScheduleModel schedule) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await ScheduleService.createSchedule(schedule);
      if (success) {
        // Reload schedules to get the updated list
        await loadAllSchedules();
        return true;
      } else {
        _setError('Failed to create schedule');
        return false;
      }
    } catch (e) {
      _setError('Failed to create schedule: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing schedule
  Future<bool> updateSchedule(ScheduleModel schedule) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await ScheduleService.updateSchedule(schedule);
      if (success) {
        // Reload schedules to get the updated list
        await loadAllSchedules();
        return true;
      } else {
        _setError('Failed to update schedule');
        return false;
      }
    } catch (e) {
      _setError('Failed to update schedule: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a schedule
  Future<bool> deleteSchedule(String scheduleId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await ScheduleService.deleteSchedule(scheduleId);
      if (success) {
        // Reload schedules to get the updated list
        await loadAllSchedules();
        return true;
      } else {
        _setError('Failed to delete schedule');
        return false;
      }
    } catch (e) {
      _setError('Failed to delete schedule: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get schedules for a specific day
  List<ScheduleModel> getSchedulesForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return _eventsByDate[dateKey] ?? [];
  }

  // Get today's schedules
  List<ScheduleModel> getTodaySchedules() {
    final today = DateTime.now();
    return getSchedulesForDay(today);
  }

  // Get upcoming schedules (next 7 days)
  List<ScheduleModel> getUpcomingSchedules() {
    final today = DateTime.now();
    final endDate = today.add(const Duration(days: 7));

    List<ScheduleModel> upcoming = [];
    for (final schedule in _schedules) {
      if (schedule.date.isAfter(today.subtract(const Duration(days: 1))) &&
          schedule.date.isBefore(endDate)) {
        upcoming.add(schedule);
      }
    }

    return upcoming;
  }

  // Check for schedule conflicts
  Future<bool> checkScheduleConflict(
    DateTime date,
    String time,
    String? excludeScheduleId,
  ) async {
    try {
      return await ScheduleService.checkScheduleConflict(
        date,
        time,
        excludeScheduleId,
      );
    } catch (e) {
      _setError('Failed to check schedule conflict: $e');
      return false;
    }
  }

  // Update student attendance
  Future<bool> updateAttendance(
    String scheduleId,
    String studentId,
    bool isPresent,
  ) async {
    try {
      return await ScheduleService.updateStudentAttendance(
        scheduleId,
        studentId,
        isPresent,
      );
    } catch (e) {
      _setError('Failed to update attendance: $e');
      return false;
    }
  }

  // Get attendance for a schedule
  Future<Map<String, bool>> getAttendance(String scheduleId) async {
    try {
      return await ScheduleService.getScheduleAttendance(scheduleId);
    } catch (e) {
      _setError('Failed to get attendance: $e');
      return {};
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _organizeSchedulesByDate() {
    _eventsByDate.clear();
    for (final schedule in _schedules) {
      final dateKey = DateTime(
        schedule.date.year,
        schedule.date.month,
        schedule.date.day,
      );
      _eventsByDate.putIfAbsent(dateKey, () => []);
      _eventsByDate[dateKey]!.add(schedule);
    }
  }

  // Clear all data
  void clear() {
    _schedules.clear();
    _eventsByDate.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
