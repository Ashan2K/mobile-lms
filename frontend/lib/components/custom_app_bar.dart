import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;
  final List<Widget>? additionalActions;

  const CustomAppBar({
    Key? key,
    this.onMenuPressed,
    this.onNotificationPressed,
    this.additionalActions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.black),
        onPressed: onMenuPressed ?? () {},
      ),
      actions: [
        if (additionalActions != null) ...additionalActions!,
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined, color: Colors.black),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: const Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            showNotificationPanel(context);
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void showNotificationPanel(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => const NotificationPanel(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class NotificationPanel extends StatelessWidget {
  const NotificationPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: kToolbarHeight, right: 8),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 320,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNotificationHeader(),
                const Divider(height: 1),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildNotificationItem(
                          'New Exam Available',
                          'EPS-TOPIK Mock Test 3 is now available.',
                          DateTime.now().subtract(const Duration(minutes: 30)),
                          Icons.assignment,
                          Colors.blue,
                          isUnread: true,
                        ),
                        _buildNotificationItem(
                          'Class Schedule Update',
                          'Tomorrow\'s class will start at 7:00 PM.',
                          DateTime.now().subtract(const Duration(hours: 2)),
                          Icons.schedule,
                          Colors.orange,
                          isUnread: true,
                        ),
                        _buildNotificationItem(
                          'Study Material Added',
                          'New vocabulary list has been added to your course.',
                          DateTime.now().subtract(const Duration(days: 1)),
                          Icons.book,
                          Colors.green,
                        ),
                        _buildNotificationItem(
                          'Payment Reminder',
                          'Your next payment is due in 3 days.',
                          DateTime.now().subtract(const Duration(days: 2)),
                          Icons.payment,
                          Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                _buildNotificationFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
            ),
            child: const Text('Mark all as read'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String message,
    DateTime time,
    IconData icon,
    Color color, {
    bool isUnread = false,
  }) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? Colors.blue.withOpacity(0.05) : Colors.white,
          border: const Border(
            bottom: BorderSide(color: Color(0xFFEEEEEE)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getTimeAgo(time),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
            ),
            child: const Text('View all'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
