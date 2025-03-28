import 'package:flutter/material.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/models/user_role.dart';
import 'package:frontend/services/base_url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<UserModel?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final user = UserModel.fromJson(data['user']);
        final token = data['token'];

        // Store token and user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user', json.encode(user.toJson()));

        return user;
      }
      return null;
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }

  static Future<bool> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    required UserRole role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fname': firstName,
          'lname': lastName,
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
          'role': role.toString().split('.').last,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Signup error: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      return UserModel.fromJson(json.decode(userJson));
    }
    return null;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static bool hasRole(UserModel? user, UserRole role) {
    return user?.role == role;
  }
}
