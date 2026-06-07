import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smart_school_unified/modules/teacher/providers/notification_provider.dart';
import 'package:intl/intl.dart';
class TeacherNotificationScreen extends StatelessWidget {
  const TeacherNotificationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<TeacherNotificationProvider>();
    final notifications = notificationProvider.notifications;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          'Notifications',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(context, notification);
              },
            ),
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 64.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'No notifications yet',
            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16.sp),
          ),
        ],
      ),
    );
  }
  Widget _buildNotificationCard(BuildContext context, dynamic notification) {
    final provider = context.read<TeacherNotificationProvider>();
    final dateStr = DateFormat('MMM dd, hh:mm a').format(notification.createdAt);
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16.r)),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => provider.deleteNotification(notification.id),
      child: GestureDetector(
        onTap: () {
          if (!notification.isRead) {
            provider.markAsRead(notification.id);
          }
          _showNotificationDetail(context, notification);
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: notification.isRead ? Colors.grey[100]! : const Color(0xFF4F46E5).withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _getIconColor(notification.type).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getIcon(notification.type), color: _getIconColor(notification.type), size: 20.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notification.title,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          dateStr,
                          style: GoogleFonts.outfit(fontSize: 11.sp, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      notification.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(fontSize: 13.sp, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _showNotificationDetail(BuildContext context, dynamic notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(notification.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(notification.message, style: GoogleFonts.outfit(fontSize: 15.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
  IconData _getIcon(String type) {
    switch (type) {
      case 'homework': return Icons.assignment_rounded;
      case 'attendance': return Icons.how_to_reg_rounded;
      default: return Icons.notifications_rounded;
    }
  }
  Color _getIconColor(String type) {
    switch (type) {
      case 'homework': return Colors.blue;
      case 'attendance': return Colors.orange;
      default: return const Color(0xFF4F46E5);
    }
  }
}