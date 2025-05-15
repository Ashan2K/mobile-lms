import 'package:flutter/material.dart';
import 'package:frontend/services/notification_service.dart';

class NotificationsOverlay extends StatefulWidget {
  final int unreadCount;
  final VoidCallback onMarkAllRead;

  const NotificationsOverlay({
    Key? key,
    required this.unreadCount,
    required this.onMarkAllRead,
  }) : super(key: key);

  @override
  State<NotificationsOverlay> createState() => _NotificationsOverlayState();
}

class _NotificationsOverlayState extends State<NotificationsOverlay> {
  final List<Map<String, String>> _notifications = [
    {
      'title': 'Upcoming Class Reminder',
      'message': 'Korean Language class starts in 30 minutes',
      'time': 'Just now',
      'type': 'reminder',
    },
  ];

  void _showCreateNotificationDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  messageController.text.isNotEmpty) {
                _createNotification(
                    titleController.text, messageController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
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
      //TODO: Implemnt
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  onPressed: _showCreateNotificationDialog,
                ),
              ],
            ),
          ),
          // Notifications List
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
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
          // Footer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}
