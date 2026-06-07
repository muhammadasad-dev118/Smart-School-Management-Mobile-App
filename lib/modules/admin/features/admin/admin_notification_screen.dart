import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:smart_school_unified/modules/admin/providers/notification_provider.dart';
class AdminNotificationScreen extends StatelessWidget {
  const AdminNotificationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Student Requests', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 80.sp, color: Colors.grey[300]),
                  SizedBox(height: 16.h),
                  Text('No requests yet', style: GoogleFonts.outfit(fontSize: 18.sp, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(20.r),
            itemCount: provider.notifications.length,
            itemBuilder: (context, index) {
              final notification = provider.notifications[index];
              final isUnread = notification.status == 'Unread';
              final isReplied = notification.status == 'Replied';
              return Container(
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: isUnread
                      ? Border.all(color: const Color(0xFF4F46E5).withValues(alpha: 0.3), width: 1.5)
                      : (isReplied ? Border.all(color: Colors.green.withValues(alpha: 0.2), width: 1) : null),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.r),
                  onTap: () {
                    if (isUnread) provider.markAsRead(notification.id);
                    _showDetailsDialog(context, provider, notification);
                  },
                  leading: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: isUnread ? const Color(0xFF4F46E5).withValues(alpha: 0.1) : Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      notification.type == 'Password Reset / Support' ? Icons.lock_reset_rounded : Icons.support_agent_rounded,
                      color: isUnread ? const Color(0xFF4F46E5) : Colors.grey[500],
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.email,
                          style: GoogleFonts.outfit(fontWeight: isUnread ? FontWeight.bold : FontWeight.w600, fontSize: 15.sp),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(color: const Color(0xFF4F46E5), borderRadius: BorderRadius.circular(12.r)),
                          child: Text('NEW', style: GoogleFonts.outfit(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                        ),
                      if (isReplied)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12.r)),
                          child: Text('REPLIED', style: GoogleFonts.outfit(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4.h),
                      Text(
                        notification.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(fontSize: 13.sp, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        DateFormat('MMM dd, hh:mm a').format(notification.createdAt),
                        style: GoogleFonts.outfit(fontSize: 11.sp, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline_rounded, color: Colors.red[300], size: 20.sp),
                    onPressed: () => _showDeleteConfirmation(context, provider, notification.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  void _showDetailsDialog(BuildContext context, NotificationProvider provider, dynamic notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text('Request Details', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailItem('Type', notification.type),
              _detailItem('From', notification.email),
              _detailItem('Date', DateFormat('MMM dd, yyyy - hh:mm a').format(notification.createdAt)),
              _detailItem('Status', notification.status),
              SizedBox(height: 16.h),
              Text('Message:', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14.sp)),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12.r)),
                child: Text(notification.message, style: GoogleFonts.outfit(fontSize: 14.sp, color: Colors.grey[700])),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Close', style: GoogleFonts.outfit(fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showReplyDialog(context, provider, notification);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
            child: Text(notification.status == 'Replied' ? 'Reply Again' : 'Reply', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
  void _showReplyDialog(BuildContext context, NotificationProvider provider, dynamic notification) {
    final replyController = TextEditingController();
    bool isSubmitting = false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Text('Reply to ${notification.email}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16.sp)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: replyController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Type your response here...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (replyController.text.isEmpty) return;
                      setDialogState(() => isSubmitting = true);
                      try {
                        await provider.replyToRequest(notification.id, notification.email, replyController.text);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reply sent successfully!')));
                        }
                      } catch (e) {
                        setDialogState(() => isSubmitting = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to send reply.')));
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
              child: isSubmitting
                  ? SizedBox(width: 20.w, height: 20.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Send Reply', style: GoogleFonts.outfit(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
  Widget _detailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.sp)),
          Expanded(child: Text(value, style: GoogleFonts.outfit(fontSize: 13.sp, color: Colors.grey[700]))),
        ],
      ),
    );
  }
  void _showDeleteConfirmation(BuildContext context, NotificationProvider provider, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Request'),
        content: const Text('Are you sure you want to delete this request?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.deleteNotification(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}