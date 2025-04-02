import 'package:frontend/models/user_role.dart';

class UserModel {
  final String id;
  final String fname;
  final String lname;
  final String email;
  final UserRole role;
  final String? phoneNumber;
  final String? status;
  final String? imageUrl;
  final String? stdId;

  UserModel({
    required this.id,
    required this.fname,
    required this.lname,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.status,
    this.imageUrl,
    this.stdId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    UserRole role;
    try {
      role = UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () =>
            UserRole.student, // Default to 'student' if role is invalid
      );
    } catch (e) {
      role = UserRole.student; // Fallback to 'student' if role is invalid
    }

    return UserModel(
      id: json['uid'],
      stdId: json['stdId'],
      imageUrl: json['imageUrl'],
      status: json['status'],
      fname: json['fname'],
      lname: json['lname'],
      email: json['email'],
      role: role,
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': id,
      'stdId': stdId,
      'imageUrl': imageUrl,
      'status': status,
      'fname': fname,
      'lname': lname,
      'email': email,
      'role': role.toString().split('.').last,
      'phoneNumber': phoneNumber,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'stdId': stdId,
      'name': fname + " " + lname,
      'status': status,
      'imageUrl': imageUrl,
      'uid': id
    };
  }
}
