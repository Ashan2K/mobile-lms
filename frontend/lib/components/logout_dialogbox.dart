import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';

class LogOutDialogBox extends StatelessWidget {
  const LogOutDialogBox({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to log out?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          onPressed: () async {
            await AuthService.logout();

            Navigator.pop(context); // Close the dialog
            Navigator.pushReplacementNamed(
                context, '/login'); // Navigate to login
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700],
          ),
          child: const Text('Logout', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
