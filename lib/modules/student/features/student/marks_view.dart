import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:smart_school_unified/modules/student/providers/auth_provider.dart';
import 'package:smart_school_unified/modules/student/features/student/models/student_model.dart';
import 'package:smart_school_unified/services/firebase/student_firestore_service.dart';
class MarksView extends StatelessWidget {
  const MarksView({super.key});
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
          'Academic Results',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getMarksForClass(fullClassName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final allDocs = snapshot.data?.docs ?? [];
          final normalizedSearchClass = _normalize(fullClassName);
          final docs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _normalize(data['className'] ?? '') == normalizedSearchClass;
          }).toList();
          final sortedDocs = List<QueryDocumentSnapshot>.from(docs);
          sortedDocs.sort((a, b) {
            final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime);
          });
          final studentMarksDocs = sortedDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            if (data.containsKey('studentId')) {
              return data['studentId'] == studentId;
            }
            final marksData = data['marks'];
            if (marksData is Map) {
              return marksData.containsKey(studentId);
            }
            return false;
          }).toList();
          if (studentMarksDocs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.grade_outlined, size: 64.sp, color: Colors.grey[300]),
                  SizedBox(height: 16.h),
                  Text(
                    'No marks uploaded yet.',
                    style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16.sp),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(20.w),
            itemCount: studentMarksDocs.length,
            itemBuilder: (context, index) {
              final data = studentMarksDocs[index].data() as Map<String, dynamic>;
              final String examTitle = data['examTitle'] ?? 'Exam';
              final String subject = data['subject'] ?? 'Subject';
              final String teacherName = data['teacherName'] ?? 'Teacher';
              double marksObtained = 0.0;
              final marksField = data['marks'];
              if (marksField is num) {
                marksObtained = marksField.toDouble();
              } else if (marksField is Map) {
                marksObtained = (marksField[studentId] as num?)?.toDouble() ?? 0.0;
              }
              final double totalMarks = (data['totalMarks'] as num?)?.toDouble() ?? 100.0;
              final DateTime date = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
              return _buildMarkCard(context, examTitle, subject, teacherName, marksObtained, totalMarks, date);
            },
          );
        },
      ),
    );
  }
  Widget _buildMarkCard(BuildContext context, String title, String subject, String teacher, double marks, double total, DateTime date) {
    final double percentage = (marks / total) * 100;
    return InkWell(
      onTap: () => _showMarkDetails(context, title, subject, teacher, marks, total, percentage, date),
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              alignment: Alignment.center,
              child: Text(
                marks.toStringAsFixed(0),
                style: GoogleFonts.outfit(color: const Color(0xFF4F46E5), fontSize: 22.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16.sp, color: const Color(0xFF1E293B))),
                  SizedBox(height: 4.h),
                  Text(subject, style: GoogleFonts.outfit(color: const Color(0xFF6366F1), fontWeight: FontWeight.w600, fontSize: 13.sp)),
                  Text('Percentage: ${percentage.toStringAsFixed(1)}%', style: GoogleFonts.outfit(color: Colors.green, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
  void _showMarkDetails(BuildContext context, String title, String subject, String teacher, double marks, double total, double percentage, DateTime date) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(2.r)))),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.outfit(fontSize: 22.sp, fontWeight: FontWeight.bold)),
                    Text(subject, style: GoogleFonts.outfit(fontSize: 16.sp, color: const Color(0xFF6366F1), fontWeight: FontWeight.w600)),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12.r)),
                  child: Text('${percentage.toStringAsFixed(1)}%', style: GoogleFonts.outfit(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16.sp)),
                ),
              ],
            ),
            SizedBox(height: 32.h),
            _buildDetailRow(Icons.grade_rounded, 'Marks Obtained', '${marks.toStringAsFixed(0)} / ${total.toStringAsFixed(0)}'),
            _buildDetailRow(Icons.person_rounded, 'Teacher', teacher),
            _buildDetailRow(Icons.calendar_today_rounded, 'Date', DateFormat('MMMM dd, yyyy').format(date)),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                child: Text('Close', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12.r)),
            child: Icon(icon, color: const Color(0xFF64748B), size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12.sp)),
              Text(value, style: GoogleFonts.outfit(fontSize: 15.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
            ],
          ),
        ],
      ),
    );
  }
  String _normalize(String name) {
    return name.toLowerCase()
        .replaceAll('class', '')
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .trim();
  }
}