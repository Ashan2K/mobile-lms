import 'package:flutter/material.dart';
import 'package:frontend/services/notification_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class NotificationsScreen extends StatefulWidget {
  final int unreadCount;
  final VoidCallback onMarkAllRead;

  const NotificationsScreen({
    Key? key,
    required this.unreadCount,
    required this.onMarkAllRead,
  }) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, String>> _notifications = [
    {
      'title': 'Upcoming Class Reminder',
      'message': 'Korean Language class starts in 30 minutes',
      'time': 'Just now',
      'type': 'reminder',
    },
  ];

  final ImagePicker _picker = ImagePicker();

  void _showCreateNotificationDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String selectedType = 'notification';
    File? selectedImage;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.notifications,
                            color: Colors.blue[700],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Create Notification',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Notification Type Selection
                    const Text(
                      'Notification Type:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'notification',
                          groupValue: selectedType,
                          onChanged: (v) => setState(() => selectedType = v!),
                        ),
                        const Text('Notification'),
                        const SizedBox(width: 16),
                        Radio<String>(
                          value: 'hero_banner',
                          groupValue: selectedType,
                          onChanged: (v) => setState(() => selectedType = v!),
                        ),
                        const Text('Hero Banner'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title (for notification type)
                    if (selectedType == 'notification') ...[
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          hintText: 'Enter notification title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.edit),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter title' : null,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Image picker (for hero banner type)
                    if (selectedType == 'hero_banner') ...[
                      GestureDetector(
                        onTap: () async {
                          final XFile? image = await _picker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 800,
                            maxHeight: 600,
                            imageQuality: 85,
                          );
                          if (image != null) {
                            setState(() {
                              selectedImage = File(image.path);
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade50,
                          ),
                          child: selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    selectedImage!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 120,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 40,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap to select image',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Description
                    TextFormField(
                      controller: descriptionController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: selectedType == 'notification'
                            ? 'Message'
                            : 'Description',
                        hintText: selectedType == 'notification'
                            ? 'Enter notification message'
                            : 'Enter banner description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter description' : null,
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              if (selectedType == 'hero_banner' &&
                                  selectedImage == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please select an image for hero banner'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              if (selectedType == 'notification') {
                                _createNotification(titleController.text,
                                    descriptionController.text);
                              } else {
                                _createHeroBanner(
                                    selectedImage!, descriptionController.text);
                              }
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Create'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'assignment':
        return Icons.assignment;
      case 'attendance':
        return Icons.check_circle;
      case 'reminder':
        return Icons.notifications;
      default:
        return Icons.info;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'assignment':
        return Colors.blue;
      case 'attendance':
        return Colors.green;
      case 'reminder':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _createNotification(
      String titleController, String messageController) async {
    try {
      await NotificationService.sendNotification(
          titleController, messageController);
    } catch (e) {
      //TODO: Implement error handling
    }
  }

  Future<void> _createHeroBanner(File image, String description) async {
    try {
      // TODO: Implement hero banner creation
      // This would typically involve uploading the image and creating a banner
      print(
          'Creating hero banner with image: ${image.path} and description: $description');
    } catch (e) {
      //TODO: Implement error handling
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateNotificationDialog,
            tooltip: 'Create Notification',
          ),
        ],
      ),
      body: Column(
        children: [
          // Optionally, show unread count or other header info here
          if (widget.unreadCount > 0)
            Container(
              width: double.infinity,
              color: Colors.blue[50],
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                '${widget.unreadCount} unread notifications',
                style: const TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _notifications.length +
                  2, // +2 for See More and Mark all as read
              itemBuilder: (context, index) {
                if (index == _notifications.length) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement see more functionality
                        },
                        child: const Text('See More'),
                      ),
                    ),
                  );
                }
                if (index == _notifications.length + 1) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextButton(
                        onPressed: widget.onMarkAllRead,
                        child: const Text('Mark all as read'),
                      ),
                    ),
                  );
                }
                final notification = _notifications[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getColorForType(notification['type']!)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getIconForType(notification['type']!),
                        color: _getColorForType(notification['type']!),
                      ),
                    ),
                    title: Text(
                      notification['title']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification['message']!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification['time']!,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Handle notification tap
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
