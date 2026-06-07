import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smart_school_unified/modules/teacher/providers/auth_provider.dart';
import 'package:smart_school_unified/core/constants/app_constants.dart';
import 'attendance_screen.dart';
import '../homework/homework_upload_screen.dart';
import '../homework/homework_submissions_screen.dart';
import '../marks/marks_upload_screen.dart';
class AttendanceClassSelectionScreen extends StatelessWidget {
  final String actionType;
  const AttendanceClassSelectionScreen({super.key, required this.actionType});
  @override
  Widget build(BuildContext context) {
    final teacher = context.watch<TeacherAuthProvider>().currentTeacher;
    final List<String> classes = teacher?.assignedClasses ?? [];
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          'Select Class for $actionType',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
      ),
      body: classes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.class_outlined, size: 64.sp, color: Colors.grey[300]),
                  SizedBox(height: 16.h),
                  Text(
                    'No classes assigned to you.',
                    style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16.sp),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Please contact admin.',
                    style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12.sp),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(24.w),
              itemCount: classes.length,
              itemBuilder: (context, index) {
                final className = classes[index];
                return _buildClassCard(context, className);
              },
            ),
    );
  }
  Widget _buildClassCard(BuildContext context, String className) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        leading: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(Icons.school_rounded, color: AppConstants.primaryColor, size: 24.sp),
        ),
        title: Text(
          'Class $className',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        subtitle: Text('Tap to open students list', style: GoogleFonts.outfit(fontSize: 12.sp, color: Colors.grey)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16.sp, color: Colors.grey[400]),
        onTap: () {
          if (actionType == 'Attendance') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => AttendanceScreen(className: className)));
          } else if (actionType == 'Homework') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeworkUploadScreen()));
          } else if (actionType == 'Check Homework') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => HomeworkSubmissionsScreen(className: className)));
          } else if (actionType == 'Marks') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => MarksUploadScreen(className: className)));
          }
        },
      ),
    );
  }
}