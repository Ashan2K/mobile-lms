import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/models/course_model.dart';
import 'package:frontend/services/base_url.dart';
import 'package:http/http.dart' as http;

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
    final response = await http.post(Uri.parse('$url/api/load-course'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);

      return jsonResponse
          .map((course) => CourseModel.fromJson(course))
          .toList();
    } else {
      throw Exception('Failed to load courses');
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
}
