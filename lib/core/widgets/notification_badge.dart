import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../services/notifications/notification_provider.dart';
class NotificationBadge extends StatelessWidget {
  final String userId;
  final VoidCallback onTap;
  final Color iconColor;
  const NotificationBadge({
    super.key,
    required this.userId,
    required this.onTap,
    this.iconColor = Colors.black,
  });
  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotificationProvider>(
      builder: (context, provider, _) {
        final unread = provider.unreadCount(userId);
        final hasUnread = unread > 0;
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              onPressed: onTap,
              icon: Icon(
                hasUnread ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                color: hasUnread ? Colors.redAccent : iconColor,
                size: 26.sp,
              ),
            ),
            if (hasUnread)
              Positioned(
                right: 8.w,
                top: 8.h,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 16.w,
                    minHeight: 16.w,
                  ),
                  child: Center(
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}