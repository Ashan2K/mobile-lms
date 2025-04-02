import 'package:flutter/material.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/models/user_role.dart';
import 'package:frontend/services/base_url.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
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
        debugPrint(prefs.getString('user'));

        return user;
      }
      return null;
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }

  static Future<UserModel?> getUserFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Retrieve the token and user data from shared preferences
      String userJson =
          prefs.getString("user") ?? "{}"; // Default to empty JSON if not found

      if (userJson != null) {
        // Parse the user from JSON
        Map<String, dynamic> userMap = json.decode(userJson);
        UserModel user = UserModel.fromJson(userMap);

        // You can now use the token and user object for authentication, API calls, etc.
        return user;
      } else {
        // If no token or user data is found, return null (or handle as needed)
        return null;
      }
    } catch (e) {
      debugPrint('Error retrieving user from shared preferences: $e');
      return null;
    }
  }

  static Future signup({
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
          'password': password,
          'phoneNumber': phoneNumber,
          'role': role.toString().split('.').last,
        }),
      );
      if (response != null) {
        debugPrint('Response: ${response.body}');
      } else {
        debugPrint('Response is null');
      }
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return data is Map<String, dynamic> ? data : null;
      } else {
        // Handle non-201 status codes properly
        return null; // Returning null on failure
      }
    } catch (e) {
      debugPrint('Signup error: $e');
      return null;
    }
  }

  static Future<void> sendOtp(String phoneNumber) async {
    final response = await http.post(
      Uri.parse('$url/api/create-otp'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'phoneNumber': phoneNumber}),
    );

    if (response.statusCode == 200) {
      print("OTP sent successfully");
    } else {
      print("Error sending OTP: ${response.body}");
    }
  }

  static Future<void> verifyOtp(
      String phoneNumber, String otp, String uId) async {
    final response = await http.post(
      Uri.parse('$url/api/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body:
          json.encode({'phoneNumber': phoneNumber, 'otp': otp, 'userId': uId}),
    );

    if (response.statusCode == 200) {
      print("OTP verified successfully");
    } else {
      print("Error verifying OTP: ${response.body}");
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
