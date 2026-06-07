import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_school_unified/modules/student/providers/auth_provider.dart';
import 'package:smart_school_unified/modules/student/features/student/models/student_model.dart';
import 'package:smart_school_unified/services/firebase/student_firestore_service.dart';
class AttendanceView extends StatelessWidget {
  const AttendanceView({super.key});
  @override
  Widget build(BuildContext context) {
    final StudentModuleStudentModel? student = context.watch<StudentAuthProvider>().currentStudent;
    final service = StudentFirestoreService();
    if (student == null) {
      return const Scaffold(body: Center(child: Text('Please login first')));
    }
    final String studentId = student.id;
    final String className = student.className;
    final String section = student.section;
    final String fullClassName = section.isNotEmpty ? '$className-$section' : className;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          'My Attendance',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getAttendanceForClass(fullClassName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final allDocs = snapshot.data?.docs ?? [];
          final normalizedSearchClass = service.normalize(fullClassName);
          final docs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return service.normalize(data['className'] ?? '') == normalizedSearchClass;
          }).toList();
          final sortedDocs = List<QueryDocumentSnapshot>.from(docs);
          sortedDocs.sort((a, b) {
            final aDate = (a.data() as Map<String, dynamic>)['date'] as Timestamp;
            final bDate = (b.data() as Map<String, dynamic>)['date'] as Timestamp;
            return bDate.compareTo(aDate);
          });
          if (sortedDocs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 64.sp, color: Colors.grey[300]),
                  SizedBox(height: 16.h),
                  Text(
                    'No attendance records found.',
                    style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16.sp),
                  ),
                ],
              ),
            );
          }
          final filteredDocs = sortedDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final attendance = data['attendance'] as Map<String, dynamic>?;
            return attendance != null && attendance.containsKey(studentId);
          }).toList();
          int presentCount = 0;
          for (var doc in filteredDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final attendance = data['attendance'] as Map<String, dynamic>;
            if (attendance[studentId] == true) presentCount++;
          }
          double percentage = filteredDocs.isEmpty ? 0 : (presentCount / filteredDocs.length) * 100;
          return Column(
            children: [
              _buildSummaryHeader(presentCount, filteredDocs.length - presentCount, percentage),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(20.w),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final data = filteredDocs[index].data() as Map<String, dynamic>;
                    final bool isPresent = data['attendance'][studentId] == true;
                    final DateTime date = (data['date'] as Timestamp).toDate();
                    final String teacherName = data['teacherName'] ?? 'Teacher';
                    final String subject = data['subject'] ?? 'General';
                    return _buildAttendanceCard(date, isPresent, teacherName, subject);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  Widget _buildSummaryHeader(int present, int absent, double percentage) {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Overall Attendance', style: GoogleFonts.outfit(color: Colors.white60, fontSize: 14.sp)),
              Text('${percentage.toStringAsFixed(1)}%',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 32.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            children: [
              _buildSimpleStat('Present', present.toString(), Colors.greenAccent),
              SizedBox(width: 16.w),
              _buildSimpleStat('Absent', absent.toString(), Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildSimpleStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(color: color, fontSize: 20.sp, fontWeight: FontWeight.bold)),
        Text(label, style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12.sp)),
      ],
    );
  }
  Widget _buildAttendanceCard(DateTime date, bool isPresent, String teacherName, String subject) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            padding: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(
              color: (isPresent ? Colors.green : Colors.red).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Text(DateFormat('dd').format(date),
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18.sp, color: isPresent ? Colors.green : Colors.red)),
                Text(DateFormat('MMM').format(date),
                    style: GoogleFonts.outfit(fontSize: 12.sp, color: isPresent ? Colors.green : Colors.red)),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                Text('Teacher: $teacherName', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13.sp)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isPresent ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              isPresent ? 'Present' : 'Absent',
              style: GoogleFonts.outfit(color: isPresent ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }
}