import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_school_unified/services/firebase/teacher_firestore_service.dart';
import 'package:smart_school_unified/modules/teacher/providers/auth_provider.dart';
class HomeworkSubmissionsScreen extends StatelessWidget {
  final String className;
  const HomeworkSubmissionsScreen({super.key, required this.className});
  @override
  Widget build(BuildContext context) {
    final service = Provider.of<TeacherFirestoreService>(context);
    final teacher = Provider.of<TeacherAuthProvider>(context).currentTeacher;
    final teacherName = teacher?.name ?? 'Teacher';
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text('Homework Submissions', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18.sp)),
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: service.getHomeworkSubmissions(className, teacherId: teacher?.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final allSubmissions = snapshot.data ?? [];
          final submissions = allSubmissions.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return (data['status'] ?? 'Pending') == 'Pending';
          }).toList();
          if (submissions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 64.sp, color: Colors.green[200]),
                  SizedBox(height: 16.h),
                  Text('All submissions checked!', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16.sp)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(20.w),
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final data = submissions[index].data() as Map<String, dynamic>;
              final String id = submissions[index].id;
              final String studentName = data['studentName'] ?? 'Unknown';
              final String studentRollNo = data['studentRollNumber'] ?? 'N/A';
              final String studentId = data['studentId'] ?? '';
              final String status = data['status'] ?? 'Pending';
              final String feedback = data['feedback'] ?? '';
              final DateTime date = (data['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
              return Container(
                margin: EdgeInsets.only(bottom: 16.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(studentName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                            Text('Roll No: $studentRollNo', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12.sp)),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: status == 'Checked' ? Colors.green[50] : Colors.orange[50],
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            status,
                            style: GoogleFonts.outfit(color: status == 'Checked' ? Colors.green : Colors.orange, fontSize: 12.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text('Submitted on: ${DateFormat('MMM dd, hh:mm a').format(date)}', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12.sp)),
                    SizedBox(height: 12.h),
                    InkWell(
                      onTap: () async {
                        final fileData = data['fileData'];
                        final fileName = data['content'] ?? 'file';
                        if (fileData != null && fileData.isNotEmpty) {
                          String mimeType = 'application/octet-stream';
                          if (fileName.toLowerCase().endsWith('.pdf')) {
                            mimeType = 'application/pdf';
                          } else if (fileName.toLowerCase().endsWith('.png')) {
                            mimeType = 'image/png';
                          } else if (fileName.toLowerCase().endsWith('.jpg') || fileName.toLowerCase().endsWith('.jpeg')) {
                            mimeType = 'image/jpeg';
                          }
                          final dataUri = 'data:$mimeType;base64,$fileData';
                          final uri = Uri.parse(dataUri);
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } else {
                          final fileUrl = data['fileUrl'];
                          if (fileUrl != null && fileUrl.isNotEmpty) {
                            await launchUrl(Uri.parse(fileUrl), mode: LaunchMode.externalApplication);
                          } else {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('File content not found.')),
                            );
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.insert_drive_file_rounded, color: Colors.blue),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                data['content'] ?? 'No file attached',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14.sp, color: const Color(0xFF334155)),
                              ),
                            ),
                            const Icon(Icons.remove_red_eye_outlined, size: 18, color: Colors.blue),
                          ],
                        ),
                      ),
                    ),
                    if (feedback.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      Text('Feedback: $feedback', style: GoogleFonts.outfit(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 13.sp)),
                    ],
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              String homeworkTitle = data['homeworkTitle'] ?? 'Homework';
                              String subject = data['subject'] ?? 'Subject';
                              if (homeworkTitle == 'Homework' && data['homeworkId'] != null) {
                                final hwDoc = await FirebaseFirestore.instance.collection('homework').doc(data['homeworkId']).get();
                                if (hwDoc.exists) {
                                  homeworkTitle = hwDoc.data()?['title'] ?? 'Homework';
                                  subject = hwDoc.data()?['subject'] ?? 'Subject';
                                }
                              }
                              if (!context.mounted) return;
                              _showFeedbackDialog(context, id, studentId, homeworkTitle, subject, teacherName, service);
                            },
                            icon: const Icon(Icons.rate_review_rounded, size: 18, color: Colors.white),
                            label: Text(status == 'Checked' ? 'Update Feedback' : 'Give Feedback', style: const TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E293B),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
  void _showFeedbackDialog(
    BuildContext context,
    String submissionId,
    String studentId,
    String homeworkTitle,
    String subject,
    String teacherName,
    TeacherFirestoreService service
  ) {
    final feedbackController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Provide Feedback', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Homework: $homeworkTitle', style: GoogleFonts.outfit(fontSize: 14.sp, color: Colors.grey[600])),
            Text('Subject: $subject', style: GoogleFonts.outfit(fontSize: 14.sp, color: Colors.grey[600])),
            SizedBox(height: 16.h),
            TextField(
              controller: feedbackController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Great work! Keep it up.',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (feedbackController.text.isEmpty) return;
              await service.updateHomeworkFeedback(
                submissionId: submissionId,
                studentId: studentId,
                feedback: feedbackController.text,
                homeworkTitle: homeworkTitle,
                subject: subject,
                teacherName: teacherName,
              );
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback sent!')));
            },
            child: const Text('Send Feedback'),
          ),
        ],
      ),
    );
  }
}