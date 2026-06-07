import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'notice_upload_screen.dart';
import 'package:smart_school_unified/services/notifications/notification_provider.dart';
import 'package:smart_school_unified/modules/teacher/providers/auth_provider.dart';
import 'package:smart_school_unified/models/notice_model.dart';
class NoticeViewScreen extends StatefulWidget {
  const NoticeViewScreen({super.key});
  @override
  State<NoticeViewScreen> createState() => _NoticeViewScreenState();
}
class _NoticeViewScreenState extends State<NoticeViewScreen> {
  @override
  void initState() {
    super.initState();
    _markAllRead();
  }
  void _markAllRead() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final teacher = context.read<TeacherAuthProvider>().currentTeacher;
      if (teacher != null) {
        context.read<AppNotificationProvider>().markAllAsRead(teacher.id);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final teacher = context.watch<TeacherAuthProvider>().currentTeacher;
    final notificationProvider = context.watch<AppNotificationProvider>();
    final notices = notificationProvider.notices;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Notice Board',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: notices.isEmpty && notificationProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.campaign_outlined, size: 64.sp, color: Colors.grey[300]),
                      SizedBox(height: 16.h),
                      Text(
                        'No notices at the moment.',
                        style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16.sp),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(20.w),
                  itemCount: notices.length,
                  itemBuilder: (context, index) {
                    final notice = notices[index];
                    final isRead = teacher != null && notice.readBy.contains(teacher.id);
                    return GestureDetector(
                      onTap: () {
                        if (teacher != null && !isRead) {
                          notificationProvider.markAsRead(notice.id, teacher.id);
                        }
                        _showNoticeDetails(context, notice);
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16.h),
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          border: Border.all(
                            color: isRead ? Colors.grey.withValues(alpha: 0.08) : Colors.indigo.withValues(alpha: 0.2),
                            width: isRead ? 1 : 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    notice.category.toUpperCase(),
                                    style: GoogleFonts.outfit(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                if (notice.className != null) ...[
                                  SizedBox(width: 8.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      'CLASS: ${notice.className}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple,
                                      ),
                                    ),
                                  ),
                                ],
                                const Spacer(),
                                if (!isRead)
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      'UNREAD',
                                      style: GoogleFonts.outfit(fontSize: 8.sp, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Icon(
                                    Icons.campaign_rounded,
                                    color: const Color(0xFF64748B),
                                    size: 24.sp,
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notice.title,
                                        style: GoogleFonts.outfit(
                                          fontSize: 17.sp,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1E293B),
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        notice.message,
                                        style: GoogleFonts.outfit(
                                          fontSize: 14.sp,
                                          color: const Color(0xFF64748B),
                                          height: 1.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            const Divider(height: 1),
                            SizedBox(height: 12.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12.r,
                                      backgroundColor: Colors.blue[50],
                                      child: Icon(Icons.person, size: 14.sp, color: Colors.blue[700]),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'By: ${notice.sentBy}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 13.sp,
                                        color: const Color(0xFF334155),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  DateFormat('MMM dd').format(notice.timestamp),
                                  style: GoogleFonts.outfit(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'sendNotice',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NoticeUploadScreen()),
        ),
        backgroundColor: const Color(0xFF1E293B),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Send Notice',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
  void _showNoticeDetails(BuildContext context, NoticeModel notice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(32.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          notice.category.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      if (notice.className != null) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: Colors.purple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'CLASS: ${notice.className}',
                            style: GoogleFonts.outfit(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ),
                      ],
                    SizedBox(height: 20.h),
                    Text(
                      notice.title,
                      style: GoogleFonts.outfit(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      DateFormat('EEEE, MMMM dd, yyyy').format(notice.timestamp),
                      style: GoogleFonts.outfit(fontSize: 14.sp, color: const Color(0xFF94A3B8)),
                    ),
                    SizedBox(height: 24.h),
                    const Divider(),
                    SizedBox(height: 24.h),
                    Text(
                      notice.message,
                      style: GoogleFonts.outfit(
                        fontSize: 16.sp,
                        color: const Color(0xFF475569),
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 40.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48.w,
                            height: 48.w,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue[400]!, Colors.blue[700]!],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Issued By',
                                style: GoogleFonts.outfit(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                              Text(
                                notice.sentBy,
                                style: GoogleFonts.outfit(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}