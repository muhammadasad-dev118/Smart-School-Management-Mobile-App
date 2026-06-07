import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smart_school_unified/models/teacher_student_models.dart';
import 'package:smart_school_unified/services/firebase/teacher_firestore_service.dart';
import 'package:smart_school_unified/modules/teacher/providers/auth_provider.dart';
class MarksUploadScreen extends StatefulWidget {
  final String className;
  const MarksUploadScreen({super.key, required this.className});
  @override
  State<MarksUploadScreen> createState() => _MarksUploadScreenState();
}
class _MarksUploadScreenState extends State<MarksUploadScreen> {
  final Map<String, Map<String, dynamic>> _marks = {};
  final _examTitleController = TextEditingController();
  final _totalMarksController = TextEditingController(text: '100');
  bool _isSaving = false;
  @override
  Widget build(BuildContext context) {
    final service = Provider.of<TeacherFirestoreService>(context);
    final teacher = Provider.of<TeacherAuthProvider>(context).currentTeacher;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          'Upload Marks - ${widget.className}',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
      ),
      body: Column(
        children: [
          _buildExamTitleInput(),
          Expanded(
            child: StreamBuilder<List<TeacherModuleStudentModel>>(
              stream: service.getStudentsByClass(widget.className),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final students = snapshot.data ?? [];
                if (students.isEmpty) return const Center(child: Text('No students found.'));
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return _buildStudentMarkInput(student);
                  },
                );
              },
            ),
          ),
          _buildSubmitButton(service, teacher),
        ],
      ),
    );
  }
  Widget _buildExamTitleInput() {
    return Container(
      padding: EdgeInsets.all(20.w),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _examTitleController,
            decoration: InputDecoration(
              labelText: 'Exam Title (e.g. Mid Term Quiz 1)',
              labelStyle: GoogleFonts.outfit(),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              prefixIcon: const Icon(Icons.edit_note_rounded),
            ),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _totalMarksController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Total Marks (Max Marks)',
              labelStyle: GoogleFonts.outfit(),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              prefixIcon: const Icon(Icons.score_rounded),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStudentMarkInput(TeacherModuleStudentModel student) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: Colors.blue.withValues(alpha: 0.1),
            child: Text(student.rollNumber, style: GoogleFonts.outfit(fontSize: 12.sp, fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(student.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15.sp)),
          ),
          SizedBox(
            width: 80.w,
            child: TextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: (val) {
                _marks[student.id] = {
                  'marks': double.tryParse(val) ?? 0.0,
                  'email': student.email,
                };
              },
              decoration: InputDecoration(
                hintText: 'Marks',
                contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSubmitButton(TeacherFirestoreService service, TeacherModuleTeacherModel? teacher) {
    return Container(
      padding: EdgeInsets.all(24.w),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: _isSaving ? null : () => _saveMarks(service, teacher),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E293B),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          ),
          child: _isSaving
              ? const CircularProgressIndicator(color: Colors.white)
              : Text('Upload Marks', style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
  Future<void> _saveMarks(TeacherFirestoreService service, TeacherModuleTeacherModel? teacher) async {
    if (_examTitleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter exam title')));
      return;
    }
    if (_marks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter marks for at least one student')));
      return;
    }
    setState(() => _isSaving = true);
    try {
      final totalMarks = double.tryParse(_totalMarksController.text) ?? 100.0;
      await service.uploadMarks(
        className: widget.className,
        subject: teacher?.subject ?? 'General',
        teacherId: teacher?.id ?? 'Unknown',
        teacherName: teacher?.name ?? 'Teacher',
        examTitle: _examTitleController.text,
        totalMarks: totalMarks,
        marksData: _marks,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marks uploaded successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}