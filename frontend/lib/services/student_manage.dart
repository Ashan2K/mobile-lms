import 'dart:convert';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/services/base_url.dart';
import 'package:http/http.dart' as http;

class StudentManage {
  Future<List<UserModel?>?> loadStudent() async {
    try {
      final response = await http.post(Uri.parse('$url/api/load-student'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final List<dynamic> usersData = data;

        // Convert the list of raw user data into a list of UserModel objects
        List<UserModel> users = usersData.map((userJson) {
          return UserModel.fromJson(userJson);
        }).toList();

        return users;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future blockUnblockStudent(String uid) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/block-student'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'uid': uid}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return null;
    }
  }
}
