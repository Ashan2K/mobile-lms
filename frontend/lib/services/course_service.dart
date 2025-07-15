import 'dart:convert';
import 'package:frontend/models/course_model.dart';
import 'package:frontend/services/base_url.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:frontend/models/enrollment_model.dart';

class CourseService {
  Future<bool> addCourse(CourseModel course) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/create-course'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(course.toJson()),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<List<CourseModel>> fetchCourses() async {
    print('Fetching courses from $url/api/load-course');
    try {
      final response = await http.post(
        Uri.parse('$url/api/load-course'),
        headers: {'Content-Type': 'application/json'},
      );
      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Courses fetched successfully');
        List jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((course) => CourseModel.fromJson(course))
            .toList();
      }
      print('Failed to fetch courses: ${response.statusCode}');
      return [];
    } catch (e) {
      print('Error fetching courses: $e');
      return [];
    }
  }

  Future<CourseModel?> fetchCourseDetails(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/coursebyid'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id}),
      );
      if (response.statusCode == 200) {
        return CourseModel.fromJson(json.decode(response.body));
      }
    } catch (e) {
      throw Exception('Failed to load course details');
    }
  }

  static Future<bool> enrollInCourse(String courseId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/enroll-course'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'courseId': courseId, 'userId': userId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<CourseModel>> fetchEnrolledCourses(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/get-enrolled-courses'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId}),
      );
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        List enrollments = json.decode(response.body);
        List<CourseModel> courses = [];
        for (var enrollment in enrollments) {
          String courseId = enrollment['courseId'];
          CourseModel? course =
              await CourseService().fetchCourseDetails(courseId);
          if (course != null) {
            courses.add(course);
            print(course.toJson());
          }
        }

        return courses;
      }
      if (response.statusCode == 404) {
        return []; // No courses found
      } else {
        throw Exception('Failed to load enrolled courses');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load enrolled courses');
    }
  }

  static Future<bool> payMonthlyFee(
      String courseId, String userId, double amount, String month) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/pay-monthly-fee'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'courseId': courseId,
          'userId': userId,
          'amount': amount,
        }),
      );
      if (response.statusCode != 200) {
        print('Failed to pay monthly fee: ${response.body}');
        return false;
      }
      final data = json.decode(response.body);
      final clientSecret = data['clientSecret'];

      // Initialize Stripe
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'KLMS Payment',
          primaryButtonLabel: 'Pay Rs.${amount.toStringAsFixed(2)}',
          style: ThemeMode.light,
        ),
      );

      // Present the payment sheet
      await Stripe.instance.presentPaymentSheet();

      // After successful payment, notify backend to record the payment
      final recordResponse = await http.post(
        Uri.parse('$url/api/record-monthly-payment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'courseId': courseId,
          'userId': userId,
          'amount': amount.toStringAsFixed(2),
          'month': month,
        }),
      );
      if (recordResponse.statusCode == 200) {
        return true;
      } else {
        print('Failed to record monthly payment: ${recordResponse.body}');
        return false;
      }
    } catch (e) {
      print('Error paying monthly fee: $e');
      return false;
    }
  }

  /// Enrolls in a course using Stripe payment (placeholder implementation).
  /// Returns true if payment and enrollment succeed, false otherwise.
  static Future<bool> enrollInCourseWithStripe(
      double price, String courseId, String userId) async {
    try {
      // 1. Call backend to create a PaymentIntent
      final paymentIntentResponse = await http.post(
        Uri.parse('$url/api/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: json
            .encode({'amount': price, 'courseId': courseId, 'userId': userId}),
      );
      if (paymentIntentResponse.statusCode != 200) {
        print('Failed to create payment intent');
        return false;
      }
      final data = json.decode(paymentIntentResponse.body);
      final clientSecret = data['clientSecret'];
      // Optionally, get customerId and ephemeralKey if your backend provides them
      // final customerId = data['customerId'];
      // final ephemeralKey = data['ephemeralKey'];

      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'KLMS Payment',
          primaryButtonLabel: 'Pay Rs.${price.toStringAsFixed(2)}',
          style: ThemeMode.light,
        ),
      );

      // 3. Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Notify backend to enroll user in course
      final enrollResponse = await http.post(
        Uri.parse('$url/api/enroll-course'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'courseId': courseId, 'userId': userId}),
      );
      if (enrollResponse.statusCode == 200) {
        return true;
      } else {
        print('Enrollment failed');
        return false;
      }
    } catch (e) {
      print('Error in enrollInCourseWithStripe: $e');
      return false;
    }
  }

  /// Fetches enrollment info for a user in a course, including paid months.
  static Future<EnrollmentModel?> fetchEnrollment(
      String userId, String courseId) async {
    try {
      final response = await http.post(
        Uri.parse('{url}/api/get-enrollment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId, 'courseId': courseId}),
      );
      if (response.statusCode == 200) {
        return EnrollmentModel.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        return null; // Not enrolled
      } else {
        throw Exception('Failed to fetch enrollment');
      }
    } catch (e) {
      print('Error fetching enrollment: $e');
      return null;
    }
  }

  /// Records a monthly payment for a user in a course (adds the month to paidMonths).
  static Future<bool> recordMonthlyPayment(
      String userId, String courseId, String month) async {
    try {
      final response = await http.post(
        Uri.parse('{url}/api/record-monthly-payment'),
        headers: {'Content-Type': 'application/json'},
        body: json
            .encode({'userId': userId, 'courseId': courseId, 'month': month}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error recording monthly payment: $e');
      return false;
    }
  }

  /// Checks if the user has paid for the current month for a course.
  static Future<bool> hasPaidForCurrentMonth(
      String userId, String courseId) async {
    final now = DateTime.now();
    final currentMonth = "{now.year}-{now.month.toString().padLeft(2, '0')}";
    final enrollment = await fetchEnrollment(userId, courseId);
    if (enrollment == null) return false;
    return enrollment.paidMonths.contains(currentMonth);
  }

  /// Fetches all enrollments for a user and their corresponding course details.
  static Future<Map<String, dynamic>> fetchEnrollmentsAndCourses(
      String userId) async {
    List<EnrollmentModel> enrollments = [];
    Map<String, CourseModel> courseMap = {};
    try {
      final response = await http.post(
        Uri.parse('$url/api/get-enrollments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        enrollments = data.map((e) => EnrollmentModel.fromJson(e)).toList();
        // Fetch all course details for enrolled courses
        final courseIds = enrollments.map((e) => e.courseId).toSet();
        for (final courseId in courseIds) {
          final course = await CourseService().fetchCourseDetails(courseId);
          if (course != null) {
            courseMap[courseId] = course;
          }
        }
      }
    } catch (e) {
      // Handle error
    }
    return {
      'enrollments': enrollments,
      'courses': courseMap,
    };
  }

  /// Fetches payment history for a user.
  static Future<List<Map<String, dynamic>>> fetchPaymentHistory(
      String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/payment-history'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId}),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load payment history');
      }
    } catch (e) {
      print('Error fetching payment history: $e');
      return [];
    }
  }

  static Future<List<String>> getCourseDuePayments(
      String studentId, String courseId) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/get-course-due-paymentsById'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': studentId, 'courseId': courseId}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['dueMonths'] != null) {
          return List<String>.from(data['dueMonths']);
        } else {
          return [];
        }
      } else {
        print('Failed to fetch due months: \\${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching due months: $e');
      return [];
    }
  }
}
