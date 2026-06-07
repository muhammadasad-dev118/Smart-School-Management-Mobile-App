import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:smart_school_unified/modules/student/providers/auth_provider.dart';
import 'package:smart_school_unified/modules/student/features/student/models/student_model.dart';
import 'package:smart_school_unified/services/auth/logout_service.dart';
import 'attendance_view.dart';
import 'homework_view.dart';
import 'notice_screen.dart';
import 'marks_view.dart';
import 'timetable_view.dart';
import 'notification_screen.dart';
import 'package:smart_school_unified/services/firebase/student_firestore_service.dart';
import 'package:smart_school_unified/auth/login_screen.dart';
import 'package:smart_school_unified/core/widgets/notification_badge.dart';
import 'package:smart_school_unified/services/notifications/notification_provider.dart';
class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});
  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}
class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final student = context.read<StudentAuthProvider>().currentStudent;
      if (student != null) {
        final classTarget = student.className;
        final classSectionTarget = '${student.className}${student.section}';
        final classSectionHyphenTarget = '${student.className}-${student.section}';
        context.read<AppNotificationProvider>().listenToNotices([
          'student',
          student.id,
          classTarget,
          classSectionTarget,
          classSectionHyphenTarget
        ]);
      } else {
        context.read<AppNotificationProvider>().listenToNotices('student');
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final student = context.watch<StudentAuthProvider>().currentStudent;
    if (student == null) {
      return const LoginScreen();
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF4F46E5)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(radius: 30.r, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white, size: 30.sp)),
                    SizedBox(height: 10.h),
                    Text(student.name, style: GoogleFonts.outfit(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_rounded),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_rounded),
              title: const Text('My Timetable'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentTimetableView()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_rounded),
              title: const Text('Notifications'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
              onTap: () => LogoutService.logout(context),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu_rounded, color: const Color(0xFF1A1C1E), size: 24.sp),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Student Dashboard',
          style: GoogleFonts.outfit(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1C1E),
          ),
        ),
        actions: [
          NotificationBadge(
            userId: student.id,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NoticeScreen()),
            ),
          ),
          IconButton(
            onPressed: () => LogoutService.logout(context),
            icon: Icon(Icons.logout_rounded, color: const Color(0xFF1A1C1E), size: 24.sp),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(student),
            SizedBox(height: 24.h),
            Text(
              'Quick Overview',
              style: GoogleFonts.outfit(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),
            _buildStatsGrid(context),
            SizedBox(height: 24.h),
            _buildScheduleSection(student),
            SizedBox(height: 24.h),
            _buildRecentActivitySection(),
          ],
        ),
      ),
    );
  }
  Widget _buildWelcomeCard(StudentModuleStudentModel? student) {
    final name = student?.name ?? 'Student';
    final className = student?.className ?? '-';
    final section = student?.section ?? '';
    final rollNo = student?.rollNumber ?? '-';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white, size: 30.sp),
              ),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14.sp,
                    ),
                  ),
                  Text(
                    name,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildWelcomeStat('Class', '$className-$section'),
                _buildWelcomeStat('Roll No', rollNo),
                _buildDynamicAttendanceStat(student),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDynamicAttendanceStat(StudentModuleStudentModel? student) {
    if (student == null) return _buildWelcomeStat('Attendance', '0%');
    final String studentId = student.id;
    final String className = student.className;
    final String section = student.section;
    final String fullClassName = section.isNotEmpty ? '$className-$section' : className;
    final service = StudentFirestoreService();
    return StreamBuilder<QuerySnapshot>(key: ValueKey(student.id),
      stream: service.getAttendanceForClass(fullClassName),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _buildWelcomeStat('Attendance', '0%');
        final allDocs = snapshot.data!.docs;
        final normalizedSearchClass = service.normalize(fullClassName);
        final filteredDocs = allDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final attendance = data['attendance'] as Map<String, dynamic>?;
          return service.normalize(data['className'] ?? '') == normalizedSearchClass &&
                 attendance != null && attendance.containsKey(studentId);
        }).toList();
        int presentCount = 0;
        for (var doc in filteredDocs) {
          final data = doc.data() as Map<String, dynamic>;
          final attendance = data['attendance'] as Map<String, dynamic>;
          if (attendance[studentId] == true) presentCount++;
        }
        double percentage = filteredDocs.isEmpty ? 0 : (presentCount / filteredDocs.length) * 100;
        return _buildWelcomeStat('Attendance', '${percentage.toStringAsFixed(0)}%');
      },
    );
  }
  Widget _buildWelcomeStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: 12.sp,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  Widget _buildStatsGrid(BuildContext context) {
    final cards = [
      _buildStatCard(context, 'Attendance', 'View Records', Icons.calendar_today_rounded, const Color(0xFFF59E0B), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceView()))),
      _buildStatCard(context, 'Homework', 'Tasks & Work', Icons.assignment_rounded, const Color(0xFF3B82F6), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeworkView()))),
      _buildStatCard(context, 'Notices', 'News & Info', Icons.campaign_rounded, const Color(0xFF10B981), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NoticeScreen()))),
      _buildStatCard(context, 'Result/Marks', 'Academic Records', Icons.grade_rounded, const Color(0xFF8B5CF6), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarksView()))),
      _buildStatCard(context, 'Timetable', 'Class Schedule', Icons.calendar_month_rounded, const Color(0xFF6366F1), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentTimetableView()))),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 16) / 2;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards.map((card) => SizedBox(width: itemWidth, height: itemWidth / 1.1, child: card)).toList(),
        );
      },
    );
  }
  Widget _buildStatCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildRecentActivitySection() {
    final notificationProvider = context.watch<AppNotificationProvider>();
    final notices = notificationProvider.notices;
    if (notices.isEmpty) {
      return const SizedBox.shrink();
    }
    final displayNotices = notices.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: GoogleFonts.outfit(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NoticeScreen())),
              child: Text('See All', style: GoogleFonts.outfit(color: const Color(0xFF4F46E5), fontSize: 12.sp, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayNotices.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final notice = displayNotices[index];
            return InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NoticeScreen())),
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        notice.category.toLowerCase() == 'homework' ? Icons.assignment_rounded : Icons.campaign_rounded,
                        color: const Color(0xFF4F46E5),
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
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                              color: const Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            notice.timeAgo,
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF64748B),
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: Colors.grey[300], size: 20.sp),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
  Widget _buildScheduleSection(StudentModuleStudentModel? student) {
    if (student == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Schedule",
          style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 16.h),
        StreamBuilder<QuerySnapshot>(key: ValueKey(student.id),
          stream: FirebaseFirestore.instance
              .collection('timetables')
              .where('className', isEqualTo: student.className)
              .where('section', isEqualTo: student.section)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            final schedule = snapshot.data?.docs ?? [];
            if (schedule.isEmpty) {
              return Container(
                padding: EdgeInsets.all(20.w),
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
                child: Text('No classes scheduled today', style: GoogleFonts.outfit(color: Colors.grey)),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: schedule.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final data = schedule[index].data() as Map<String, dynamic>;
                return Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(color: const Color(0xFF4F46E5).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
                        child: Icon(Icons.access_time_rounded, color: const Color(0xFF4F46E5), size: 20.sp),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['subject'] ?? 'Subject', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14.sp)),
                            Text('${data['startTime']} - ${data['endTime']} | Room: ${data['room']}', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12.sp)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}