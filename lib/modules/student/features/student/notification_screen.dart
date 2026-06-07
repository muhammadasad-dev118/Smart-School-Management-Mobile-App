import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_school_unified/modules/student/providers/auth_provider.dart';
import 'package:smart_school_unified/modules/student/features/student/models/student_model.dart';
import 'package:smart_school_unified/services/firebase/student_firestore_service.dart';
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final StudentModuleStudentModel? student = context.watch<StudentAuthProvider>().currentStudent;
    final service = StudentFirestoreService();
    if (student == null) return const Scaffold(body: Center(child: Text('Login Required')));
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20.sp)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getStudentNotifications(student.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<QueryDocumentSnapshot> notifications = snapshot.data?.docs ?? [];
          notifications.sort((a, b) {
            final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 64.sp, color: Colors.grey[300]),
                  SizedBox(height: 16.h),
                  Text('No notifications yet.', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16.sp)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(20.w),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final data = notifications[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Notification';
              final message = data['message'] ?? '';
              final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
              final bool isRead = data['isRead'] == true;
              final type = data['type'] ?? 'general';
              return InkWell(
                onTap: () {
                  if (!isRead) {
                    FirebaseFirestore.instance.collection('notifications').doc(notifications[index].id).update({'isRead': true});
                  }
                  _showNotificationDetails(context, title, message, createdAt, type);
                },
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: !isRead ? Border.all(color: const Color(0xFF4F46E5).withValues(alpha: 0.3), width: 1) : null,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: _getNotificationColor(type).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_getNotificationIcon(type), color: _getNotificationColor(type), size: 20.sp),
                          ),
                          if (!isRead)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 10.w,
                                height: 10.w,
                                decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: GoogleFonts.outfit(fontWeight: isRead ? FontWeight.bold : FontWeight.w800, fontSize: 15.sp)),
                            SizedBox(height: 4.h),
                            Text(message, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(fontSize: 13.sp, color: Colors.grey[600])),
                            SizedBox(height: 8.h),
                            Text(
                              DateFormat('MMM dd, hh:mm a').format(createdAt),
                              style: GoogleFonts.outfit(fontSize: 11.sp, color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  void _showNotificationDetails(BuildContext context, String title, String message, DateTime date, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(color: _getNotificationColor(type).withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(_getNotificationIcon(type), color: _getNotificationColor(type), size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(child: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18.sp))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMM dd, yyyy • hh:mm a').format(date),
              style: GoogleFonts.outfit(fontSize: 12.sp, color: Colors.grey[500]),
            ),
            SizedBox(height: 16.h),
            Text(message, style: GoogleFonts.outfit(fontSize: 14.sp, color: const Color(0xFF374151), height: 1.5)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF4F46E5))),
          ),
        ],
      ),
    );
  }
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'homework': return Icons.assignment_turned_in_rounded;
      case 'attendance': return Icons.calendar_today_rounded;
      case 'marks': return Icons.grade_rounded;
      case 'support': return Icons.support_agent_rounded;
      default: return Icons.notifications_rounded;
    }
  }
  Color _getNotificationColor(String type) {
    switch (type) {
      case 'homework': return Colors.blue;
      case 'attendance': return Colors.orange;
      case 'marks': return Colors.purple;
      case 'support': return const Color(0xFF4F46E5);
      default: return Colors.green;
    }
  }
}