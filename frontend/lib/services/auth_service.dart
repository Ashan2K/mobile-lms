import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/models/user_role.dart';
import 'package:frontend/services/base_url.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/services/notification_service.dart';

class AuthService {
  static Future<UserModel?> login(
      String email, String password, String deviceId) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'deviceId': deviceId,
        }),
      );

      switch (response.statusCode) {
        case 200:
          final data = json.decode(response.body);
          final user = UserModel.fromJson(data['user']);
          final token = data['token'];

          // After login, you get customToken from backend

          String? idToken =
              await FirebaseAuth.instance.currentUser!.getIdToken();

          if (idToken == null) {
            print('Error: idToken is null after login');
          }

          print(idToken.toString());

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('idToken', idToken.toString());
          await prefs.setBool('is_logged_in', true);
          await prefs.setString('token', token);
          await prefs.setString('user', json.encode(user.toJson()));
          await prefs.setString('user_role', user.role.toString());
          await prefs.setString('userId', user.id.toString());

          return user;

        case 409:
          throw Exception(
              'Login denied: User is logged in on another device.your device Id is $deviceId');

        case 400:
          throw Exception('Invalid request. Please check your inputs.');

        case 401:
          throw Exception('Unauthorized. Email or password is incorrect.');

        case 403:
          throw Exception('Access denied. Contact support.');

        case 500:
          throw Exception('Server error. Please try again later.');

        default:
          throw Exception('Unexpected error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Login error: $e');
      throw Exception('Login failed: $e');
    }
  }

  static Future<UserModel?> getUserFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if user is logged in
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      if (!isLoggedIn) {
        await clearAllPreferences();
        return null;
      }

      // Retrieve the token and user data from shared preferences
      String userJson = prefs.getString("user") ?? "{}";
      String? storedRole = prefs.getString("user_role");

      if (userJson != "{}" && storedRole != null) {
        // Parse the user from JSON
        Map<String, dynamic> userMap = json.decode(userJson);
        UserModel user = UserModel.fromJson(userMap);

        // Verify that the stored role matches the user's role
        if (user.role.toString() != storedRole) {
          await clearAllPreferences();
          return null;
        }

        return user;
      } else {
        await clearAllPreferences();
        return null;
      }
    } catch (e) {
      debugPrint('Error retrieving user from shared preferences: $e');
      await clearAllPreferences();
      return null;
    }
  }

  static Future<void> clearAllPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      debugPrint('Error clearing preferences: $e');
    }
  }

  static Future<void> logout() async {
    try {
      // Remove FCM token before clearing preferences
      await NotificationService.removeFcmToken();

      // Clear all preferences
      await clearAllPreferences();
    } catch (e) {
      print("Error during logout: $e");
      throw Exception("Error during logout: $e");
    }
  }

  static Future signup(
      {required String firstName,
      required String lastName,
      required String email,
      required String phoneNumber,
      required String password,
      required UserRole role,
      required String deviceId,
      required String address1,
      String? address2}) async {
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
          'deviceId': deviceId,
          'address1': address1,
          'address2': address2
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

  static Future<String> uploadFileToFirebase(File file, String folder) async {
    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final Reference storageRef =
        FirebaseStorage.instance.ref().child(folder).child(fileName);
    final SettableMetadata metadata = SettableMetadata(); // <-- Add this line
    final UploadTask uploadTask =
        storageRef.putFile(file, metadata); // <-- Pass metadata
    final TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  static Future<dynamic> uploadImage(File imageFile) async {
    try {
      final String downloadUrl =
          await uploadFileToFirebase(imageFile, 'profile_pictures');
      print("Image uploaded successfully: $downloadUrl");

      UserModel? user = await getCurrentUser();
      String? token = await getToken();

      if (user == null) {
        throw Exception('User not found. Please log in again.');
      }

      if (token == null) {
        throw Exception('Authentication token not found. Please log in again.');
      }

      final response = await http.post(
        Uri.parse('$url/api/update-profile-pic'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'userId': user.id, 'fileUrl': downloadUrl}),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to update profile picture: ${response.body}');
      }

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  static Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/getProfile'),
        body: json.encode({'userId': userId}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Map<String, dynamic> userMap = data;
        return UserModel.fromJson(userMap);
      } else {
        throw Exception('Failed to fetch user: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching user by ID: $e');
      return null;
    }
  }

  static Future<bool> changePassword(String idToken, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode({
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return true; // Password changed successfully
      } else {
        throw Exception('Failed to change password: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error changing password: $e');
      return false; // Return false on failure
    }
  }
}
