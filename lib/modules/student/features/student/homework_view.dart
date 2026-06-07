import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smart_school_unified/modules/student/providers/auth_provider.dart';
import 'package:smart_school_unified/modules/student/features/student/models/student_model.dart';
import './providers/homework_provider.dart';
import 'package:smart_school_unified/services/firebase/student_firestore_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class HomeworkView extends StatefulWidget {
  const HomeworkView({super.key});
  @override
  State<HomeworkView> createState() => _HomeworkViewState();
}
class _HomeworkViewState extends State<HomeworkView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    final StudentModuleStudentModel? student = context.watch<StudentAuthProvider>().currentStudent;
    final homeworkProvider = Provider.of<StudentHomeworkProvider>(context);
    final String studentClassName = student?.className ?? '';
    final String studentSection = student?.section ?? '';
    final String fullClassName = studentSection.isNotEmpty ? '$studentClassName-$studentSection' : studentClassName;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Homework', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20.sp)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4F46E5),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4F46E5),
          indicatorWeight: 3,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14.sp),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Submitted'),
          ],
        ),
      ),
      body: StreamBuilder<List<StudentHomework>>(
        stream: homeworkProvider.getHomeworks(fullClassName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
              ),
            );
          }
          final homeworks = snapshot.data ?? [];
          return TabBarView(
            controller: _tabController,
            children: [
              _buildListView(homeworks, isPending: true),
              _buildListView(homeworks, isPending: false),
            ],
          );
        },
      ),
    );
  }
  Widget _buildListView(List<StudentHomework> homeworks, {required bool isPending}) {
    final StudentModuleStudentModel? student = context.read<StudentAuthProvider>().currentStudent;
    final studentId = student?.id ?? '';
    final homeworkProvider = context.read<StudentHomeworkProvider>();
    if (isPending) {
      return StreamBuilder<List<Map<String, dynamic>>>(
        stream: homeworkProvider.getStudentSubmissions(studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final submissions = snapshot.data ?? [];
          final submittedIds = submissions.map((s) => s['homeworkId']).toSet();
          final pendingHomeworks = homeworks.where((h) => !submittedIds.contains(h.id)).toList();
          if (pendingHomeworks.isEmpty) {
            return _buildEmptyState('No pending homework!');
          }
          return ListView.builder(
            padding: EdgeInsets.all(20.w),
            itemCount: pendingHomeworks.length,
            itemBuilder: (context, index) => _buildHomeworkCard(pendingHomeworks[index]),
          );
        },
      );
    }
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: homeworkProvider.getStudentSubmissions(studentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final submissions = snapshot.data ?? [];
        if (submissions.isEmpty) {
          return _buildEmptyState('No submitted homework yet.');
        }
        return ListView.builder(
          padding: EdgeInsets.all(20.w),
          itemCount: submissions.length,
          itemBuilder: (context, index) {
            final sub = submissions[index];
            return _buildSubmittedCard(sub);
          },
        );
      },
    );
  }
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 64.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(message, style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16.sp)),
        ],
      ),
    );
  }
  Widget _buildHomeworkCard(StudentHomework homework) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      homework.title,
                      style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(6.r)),
                          child: Text(
                            homework.subject,
                            style: GoogleFonts.outfit(fontSize: 11.sp, fontWeight: FontWeight.w600, color: const Color(0xFF4F46E5)),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'By: ${homework.teacherName}',
                          style: GoogleFonts.outfit(fontSize: 11.sp, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                'Due: ${homework.dueDate}',
                style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 12.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            homework.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(fontSize: 13.sp, color: Colors.grey[600], height: 1.5),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () => _showSubmitSheet(context, homework),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
              child: Text('Submit Homework', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSubmittedCard(Map<String, dynamic> submission) {
    final date = submission['submittedAt'] != null
        ? (submission['submittedAt'] as Timestamp).toDate()
        : DateTime.now();
    final dateStr = DateFormat('MMM dd, yyyy • hh:mm a').format(date);
    final status = submission['status'] ?? 'Pending';
    final isChecked = status == 'Checked';
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission['content'] ?? 'Untitled Submission',
                      style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                    ),
                    SizedBox(height: 4.h),
                    Text(dateStr, style: GoogleFonts.outfit(fontSize: 11.sp, color: Colors.grey[500])),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isChecked ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.outfit(
                    color: isChecked ? Colors.green : Colors.orange,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (isChecked && (submission['feedback'] ?? '').isNotEmpty) ...[
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12.r)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Teacher Feedback:', style: GoogleFonts.outfit(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1))),
                  SizedBox(height: 4.h),
                  Text(submission['feedback'], style: GoogleFonts.outfit(fontSize: 13.sp, color: const Color(0xFF475569))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  void _showSubmitSheet(BuildContext context, StudentHomework homework) {
    String? selectedFileName;
    Uint8List? selectedFileBytes;
    bool isUploadingLocal = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
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
              Text('Submit Work', style: GoogleFonts.outfit(fontSize: 22.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
              Text(homework.title, style: GoogleFonts.outfit(fontSize: 14.sp, color: Colors.grey)),
              SizedBox(height: 32.h),
              InkWell(
                onTap: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'jpg', 'png', 'doc', 'docx'],
                  );
                  if (result != null) {
                    setModalState(() {
                      selectedFileName = result.files.single.name;
                      selectedFileBytes = result.files.single.bytes;
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: selectedFileName != null ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: selectedFileName != null ? const Color(0xFF4F46E5) : Colors.grey[200]!, width: 2),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        selectedFileName != null ? Icons.description_rounded : Icons.cloud_upload_outlined,
                        size: 48.sp,
                        color: selectedFileName != null ? const Color(0xFF4F46E5) : Colors.grey[400],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        selectedFileName ?? 'Select Homework File',
                        style: GoogleFonts.outfit(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: selectedFileName != null ? const Color(0xFF4F46E5) : Colors.grey[600],
                        ),
                      ),
                      Text(
                        selectedFileName != null ? 'File Selected' : 'PDF, JPG, PNG up to 10MB',
                        style: GoogleFonts.outfit(fontSize: 12.sp, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: selectedFileName == null || isUploadingLocal ? null : () async {
                    setModalState(() => isUploadingLocal = true);
                    final StudentModuleStudentModel? student = context.read<StudentAuthProvider>().currentStudent;
                    final studentId = student?.id ?? '';
                    final studentName = student?.name ?? 'Student';
                    final studentRollNumber = student?.rollNumber ?? 'N/A';
                    final studentClassName = student?.className ?? '';
                    final studentSection = student?.section ?? '';
                    final fullClassName = studentSection.isNotEmpty ? '$studentClassName-$studentSection' : studentClassName;
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(ctx);
                    try {
                      await StudentFirestoreService().submitHomework(
                        homeworkId: homework.id,
                        homeworkTitle: homework.title,
                        subject: homework.subject,
                        studentId: studentId,
                        studentName: studentName,
                        studentRollNumber: studentRollNumber,
                        teacherId: homework.teacherId,
                        className: fullClassName,
                        fileName: selectedFileName!,
                        fileBytes: selectedFileBytes!,
                      );
                      if (!mounted) return;
                      navigator.pop();
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Homework submitted successfully!'), backgroundColor: Colors.green),
                      );
                    } catch (e) {
                      setModalState(() => isUploadingLocal = false);
                      if (!mounted) return;
                      messenger.showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    elevation: 0,
                  ),
                  child: isUploadingLocal
                    ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Turn In', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}