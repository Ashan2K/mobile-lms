import 'package:frontend/models/user_role.dart';

class UserModel {
  final String id;
  final String fname;
  final String lname;
  final String email;
  final UserRole role;
  final String? phoneNumber;

  UserModel({
    required this.id,
    required this.fname,
    required this.lname,
    required this.email,
    required this.role,
    this.phoneNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fname: json['fname'],
      lname: json['lname'],
      email: json['email'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.student,
      ),
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fname': fname,
      'lname': lname,
      'email': email,
      'role': role.toString().split('.').last,
      'phoneNumber': phoneNumber,
    };
  }
}
