import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  UserModel? _profile;
  File? _profileImage;

  Future<UserModel?> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String userJson = prefs.getString("user") ?? "{}";
    if (userJson != null) {
      Map<String, dynamic> userMap = json.decode(userJson);
      UserModel user = UserModel.fromJson(userMap);
      return user;
    } else {
      // If no token or user data is found, return null
      return null;
    }
  }

  Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      print(android.id);
      return android.id;
    } else if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      return ios.identifierForVendor ?? 'unknown';
    }
    return 'unknown_device';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      // Optional: save to local storage or upload to server
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            "Profile",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.white,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () {
                Navigator.pop(context);
              })),
      body: FutureBuilder<UserModel?>(
        future: _loadProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading profile'));
          } else if (snapshot.hasData) {
            _profile = snapshot.data;
            return SingleChildScrollView(
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
                                    border: Border.all(
                                        color: Colors.white, width: 4),
                                    color: Colors.grey[200],
                                    image: DecorationImage(
                                      image: _profileImage != null
                                          ? FileImage(_profileImage!)
                                              as ImageProvider
                                          : const AssetImage(
                                              'lib/images/profile.jpeg'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
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
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${_profile?.fname ?? ''} ${_profile?.lname ?? ''}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: _profile?.status == 'active'
                                    ? Colors.green[100]
                                    : Colors.red[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _profile?.status == 'active'
                                    ? 'Active'
                                    : 'Blocked',
                                style: TextStyle(
                                  color: _profile?.status == 'active'
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                  fontSize: 16,
                                ),
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
                            _profile?.email ?? ''),
                        _buildInfoItem(Icons.phone_outlined, 'Phone',
                            _profile?.phoneNumber ?? ''),
                        _buildInfoItem(Icons.perm_identity, 'Student Id',
                            _profile?.stdId ?? ''),
                        _buildInfoItem(Icons.location_on_outlined, 'Address',
                            'matara, sri lanka'),

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
                          Icons.edit,
                          'Edit User Name',
                          getDeviceId,
                        ),
                        _buildActionButton(
                          Icons.lock_outline,
                          'Change Password',
                          _showChangePasswordDialog,
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

                        // Add padding at the bottom for bottom navigation bar
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('No profile data found'));
          }
        },
      ),
    );
  }

//   void _showEditUsernameDialog() {
//   final TextEditingController fnameController =
//       TextEditingController(text: _profile?.fname);
//   final TextEditingController lnameController =
//       TextEditingController(text: _profile?.lname);

//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: const Text('Edit User Name'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: fnameController,
//               decoration: const InputDecoration(labelText: 'First Name'),
//             ),
//             TextField(
//               controller: lnameController,
//               decoration: const InputDecoration(labelText: 'Last Name'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 _profile = _profile?.copyWith(
//                   fname: fnameController.text,
//                   lname: lnameController.text,
//                 );
//               });
//               // Here you should also save the changes back to SharedPreferences or your backend
//               Navigator.pop(context);
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       );
//     },
//   );
// }

  void _showChangePasswordDialog() {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration:
                    const InputDecoration(labelText: 'Current Password'),
                obscureText: true,
              ),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
              TextField(
                controller: confirmPasswordController,
                decoration:
                    const InputDecoration(labelText: 'Confirm New Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Color.fromARGB(255, 57, 57, 57))),
            ),
            ElevatedButton(
              onPressed: () {
                if (newPasswordController.text ==
                    confirmPasswordController.text) {
                  // Validate and send password change request here
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Password changed successfully')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Passwords do not match')));
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  )),
              child:
                  const Text('Change', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
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
