import 'package:flutter/material.dart';
import 'package:frontend/components/notification_overlay.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;
  final List<Widget>? additionalActions;
  final List<NotificationItem>? notifications;

  const CustomAppBar({
    Key? key,
    this.onMenuPressed,
    this.onNotificationPressed,
    this.additionalActions,
    this.notifications,
  }) : super(key: key);

  void _showNotificationOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => NotificationOverlay(
        notifications: notifications ?? [],
        onClose: () => Navigator.of(context).pop(),
        onNotificationTap: (id) {
          Navigator.of(context).pop();
          // Handle notification tap
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: onMenuPressed ??
            () {
              Scaffold.of(context).openDrawer();
            },
        color: Colors.black87,
      ),
      actions: [
        if (additionalActions != null) ...additionalActions!,
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: onNotificationPressed ??
                  () => _showNotificationOverlay(context),
              color: Colors.black87,
            ),
            if (notifications != null && notifications!.any((n) => !n.isRead))
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
