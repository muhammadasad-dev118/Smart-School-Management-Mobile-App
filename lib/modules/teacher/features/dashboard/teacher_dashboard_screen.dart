import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smart_school_unified/modules/teacher/providers/auth_provider.dart';
import 'package:smart_school_unified/services/auth/logout_service.dart';
import 'package:smart_school_unified/services/auth/auth_provider.dart';
import '../notice/notice_view_screen.dart';
import '../class_management/class_management_screens.dart';
import 'package:smart_school_unified/auth/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../attendance/attendance_class_selection_screen.dart';
import '../timetable/teacher_timetable_screen.dart';
import 'package:smart_school_unified/modules/teacher/providers/timetable_provider.dart';
import 'package:smart_school_unified/models/teacher_student_models.dart';
import 'package:smart_school_unified/core/widgets/notification_badge.dart';
import 'package:smart_school_unified/services/notifications/notification_provider.dart';
class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});
  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}
class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = Provider.of<TeacherAuthProvider>(context, listen: false);
      final notificationProvider = Provider.of<AppNotificationProvider>(context, listen: false);
      auth.refreshProfile().then((_) {
        if (!mounted) return;
        if (auth.currentTeacher != null) {
          notificationProvider.listenToNotices(['teacher', auth.currentTeacher!.id]);
          Provider.of<TimetableProvider>(context, listen: false).fetchTeacherTimetable(auth.currentTeacher!.id);
        }
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    final teacher = context.watch<TeacherAuthProvider>().currentTeacher;
    if (teacher == null) {
      return const LoginScreen();
    }
    final teacherName = teacher.name;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF1E293B)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(radius: 30.r, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white, size: 30.sp)),
                    SizedBox(height: 10.h),
                    Text('Teacher Menu', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18.sp)),
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
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TeacherTimetableScreen()));
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                context.read<TeacherAuthProvider>().logout();
                context.read<AuthProvider>().logout();
              },
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
            icon: Icon(Icons.menu_rounded, color: Colors.black, size: 24.sp),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Teacher Dashboard',
          style: GoogleFonts.outfit(color: Colors.black, fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        actions: [
          NotificationBadge(
            userId: teacher.id,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NoticeViewScreen()),
            ),
          ),
          IconButton(
            onPressed: () => LogoutService.logout(context),
            icon: Icon(Icons.logout_rounded, color: Colors.black, size: 24.sp),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(teacherName),
            SizedBox(height: 32.h),
            _buildSectionHeader('Quick Actions'),
            SizedBox(height: 16.h),
            _buildQuickActionsGrid(context, teacher.assignedClasses),
            SizedBox(height: 32.h),
            _buildSectionHeader("My Schedule"),
            SizedBox(height: 16.h),
            _buildScheduleList(context),
            SizedBox(height: 32.h),
            _buildSectionHeader('Pending Tasks'),
            SizedBox(height: 16.h),
            _buildHomeworkSummary(teacher),
          ],
        ),
      ),
    );
  }
  Widget _buildWelcomeCard(String name) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 30.r,
              backgroundColor: Colors.white12,
              child: Icon(Icons.person, color: Colors.white, size: 30.sp),
            ),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good Morning,', style: GoogleFonts.outfit(color: Colors.white60, fontSize: 14.sp)),
              Text(name, style: GoogleFonts.outfit(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
    );
  }
  Widget _buildQuickActionsGrid(BuildContext context, List<String> assignedClasses) {
    final actions = [
      {'icon': Icons.how_to_reg_rounded, 'label': 'Attendance', 'color': Colors.orange},
      {'icon': Icons.calendar_month_rounded, 'label': 'Timetable', 'color': Colors.indigo},
      {'icon': Icons.assignment_rounded, 'label': 'Upload Homework', 'color': Colors.blue},
      {'icon': Icons.assignment_turned_in_rounded, 'label': 'Check Homework', 'color': Colors.cyan},
      {'icon': Icons.campaign_rounded, 'label': 'Notices', 'color': Colors.green},
      {'icon': Icons.people_rounded, 'label': 'Students', 'color': Colors.purple},
      {'icon': Icons.grade_rounded, 'label': 'Marks', 'color': Colors.red},
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 5 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16.w,
            crossAxisSpacing: 16.w,
            childAspectRatio: constraints.maxWidth > 600 ? 1.0 : 1.2,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return InkWell(
              onTap: () => _handleAction(context, action['label'] as String, assignedClasses),
              borderRadius: BorderRadius.circular(16.r),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: (action['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(action['icon'] as IconData, color: action['color'] as Color, size: 24.sp),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    action['label'] as String,
                    style: GoogleFonts.outfit(fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  void _handleAction(BuildContext context, String label, List<String> assignedClasses) {
    if (label == 'Attendance' || label == 'Upload Homework' || label == 'Marks' || label == 'Check Homework') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AttendanceClassSelectionScreen(
            actionType: label == 'Upload Homework' ? 'Homework' : label,
          ),
        ),
      );
    } else if (label == 'Notices') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const NoticeViewScreen()));
    } else if (label == 'Students') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ClassListScreen()));
    } else if (label == 'Timetable') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const TeacherTimetableScreen()));
    }
  }
  Widget _buildScheduleList(BuildContext context) {
    return Consumer<TimetableProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        final schedule = provider.teacherTimetable;
        if (schedule.isEmpty) {
          return Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
            child: Center(child: Text('No classes scheduled for today', style: GoogleFonts.outfit(color: Colors.grey))),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: schedule.length,
          itemBuilder: (context, index) {
            final entry = schedule[index];
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey[100]!),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
                    child: Icon(Icons.access_time_filled_rounded, color: Colors.blue, size: 20.sp),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${entry.subject} - ${entry.className} ${entry.section}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15.sp)),
                        Text('${entry.day} | ${entry.startTime} - ${entry.endTime}', style: GoogleFonts.outfit(color: Colors.blue, fontSize: 11.sp, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20.sp),
                ],
              ),
            );
          },
        );
      },
    );
  }
  Widget _buildHomeworkSummary(TeacherModuleTeacherModel teacher) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('homework_submissions')
          .where('status', isEqualTo: 'Pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final pendingSubmissions = snapshot.data?.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          bool isAssignedClass = teacher.assignedClasses.contains(data['className']);
          bool isTeacherSubmission = false;
          if (data.containsKey('teacherId') && data['teacherId'] != null) {
            isTeacherSubmission = data['teacherId'] == teacher.id;
          } else {
             isTeacherSubmission = true;
          }
          return isAssignedClass && isTeacherSubmission;
        }).toList() ?? [];
        if (pendingSubmissions.isEmpty) {
          return Container(
            padding: EdgeInsets.all(20.w),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey[100]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 24.sp),
                SizedBox(width: 12.w),
                Text('All homeworks are checked!', style: GoogleFonts.outfit(color: Colors.green, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }
        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: InkWell(
            onTap: () {
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Submissions to Review', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15.sp)),
                    Text('Across all your classes', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12.sp)),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12.r)),
                  child: Text('${pendingSubmissions.length} Pending', style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11.sp)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}