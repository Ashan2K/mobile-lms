import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/services/base_url.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static Future<void> getAndStoreFcmToken() async {
    try {
      // Get the current user
      final pref = await SharedPreferences.getInstance();
      String? userJson = pref.getString("user");

      if (userJson == null || userJson.isEmpty) {
        print("No user data found in SharedPreferences");
        return;
      }

      // Get the FCM token
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        print("Failed to get FCM token");
        return;
      }

      Map<String, dynamic> userMap = json.decode(userJson);
      UserModel user = UserModel.fromJson(userMap);

      // Store the FCM token in Firestore under the user's document
      await FirebaseFirestore.instance.collection('users').doc(user.id).update({
        'fcmToken': fcmToken,
      });
      print("FCM token updated for user ${user.id}");
    } catch (e) {
      print("Error in getAndStoreFcmToken: $e");
    }
  }

  static Future<void> removeFcmToken() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String? userJson = pref.getString("user");

      if (userJson == null || userJson.isEmpty) {
        print("No user data found in SharedPreferences");
        return;
      }

      Map<String, dynamic> userMap = json.decode(userJson);
      UserModel user = UserModel.fromJson(userMap);

      // Remove FCM token from Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.id).update({
        'fcmToken': FieldValue.delete(),
      });

      // Unsubscribe from FCM
      await FirebaseMessaging.instance.deleteToken();

      print("FCM token removed for user ${user.id}");
    } catch (e) {
      print("Error in removeFcmToken: $e");
    }
  }

  static Future<void> sendNotification(String title, String body,
      {String? targetRole}) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/send-notification'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'body': body,
          if (targetRole == null) 'targetRole': 'student',
          'data': {'anyAdditionalData': 'value'}
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to send notification: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending notification: $e");
      throw Exception("Error sending notification: $e");
    }
  }
}
