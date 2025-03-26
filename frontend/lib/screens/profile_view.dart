import 'package:flutter/material.dart';
import 'package:frontend/components/custom_app_bar.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header with gradient background
            Container(
              child: SafeArea(
                bottom: false,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              color: Colors.grey[200],
                              image: const DecorationImage(
                                image: AssetImage('lib/images/profile.jpeg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'K.K.R.Ashan',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Batch 23 Student',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(179, 0, 0, 0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Profile Sections
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Information Section
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoItem(Icons.email_outlined, 'Email',
                      'ravinduashan789@gmail.com'),
                  _buildInfoItem(
                      Icons.phone_outlined, 'Phone', '+94 77 123 4567'),
                  _buildInfoItem(Icons.calendar_today_outlined, 'Date of Birth',
                      '2001-01-01'),
                  _buildInfoItem(Icons.location_on_outlined, 'Address',
                      'matara, sri lanka'),

                  const SizedBox(height: 32),

                  // Course Information Section
                  const Text(
                    'Course Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoItem(Icons.class_outlined, 'Batch', 'Batch 23'),
                  _buildInfoItem(
                      Icons.school_outlined, 'Course', 'EPS-TOPIK Training'),
                  _buildInfoItem(Icons.access_time, 'Class Time',
                      'Evening (6:00 PM - 8:00 PM)'),
                  _buildInfoItem(
                      Icons.calendar_month, 'Enrollment Date', '2024-01-01'),

                  const SizedBox(height: 32),

                  // Actions Section
                  const Text(
                    'Account Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActionButton(
                    Icons.lock_outline,
                    'Change Password',
                    () {},
                  ),
                  _buildActionButton(
                    Icons.notifications_outlined,
                    'Notification Settings',
                    () {},
                  ),
                  _buildActionButton(
                    Icons.help_outline,
                    'Help & Support',
                    () {},
                  ),
                  _buildActionButton(
                    Icons.logout,
                    'Logout',
                    () {},
                    isDestructive: true,
                  ),

                  // Add padding at the bottom for bottom navigation bar
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed,
      {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: isDestructive ? Colors.red : const Color(0xFF1E1E1E),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
