import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:smart_school_unified/services/firebase/teacher_firestore_service.dart';
import 'package:smart_school_unified/modules/teacher/providers/auth_provider.dart';
class HomeworkUploadScreen extends StatefulWidget {
  const HomeworkUploadScreen({super.key});
  @override
  State<HomeworkUploadScreen> createState() => _HomeworkUploadScreenState();
}
class _HomeworkUploadScreenState extends State<HomeworkUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedClass;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _isUploading = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final teacher = context.read<TeacherAuthProvider>().currentTeacher;
      if (teacher != null && teacher.assignedClasses.isNotEmpty) {
        setState(() => _selectedClass = teacher.assignedClasses.first);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final service = Provider.of<TeacherFirestoreService>(context);
    final teacher = context.watch<TeacherAuthProvider>().currentTeacher;
    final List<String> assignedClasses = teacher?.assignedClasses ?? [];
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Assign Homework', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18.sp)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Class & Subject'),
                    SizedBox(height: 12.h),
                    _buildClassDropdown(assignedClasses),
                    SizedBox(height: 20.h),
                    _buildSectionTitle('Homework Details'),
                    SizedBox(height: 12.h),
                    _buildTextField(
                      controller: _titleController,
                      label: 'Topic Title',
                      hint: 'e.g. Newton\'s Laws of Motion',
                      icon: Icons.title_rounded,
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description / Instructions',
                      hint: 'Solve exercises 1 to 5 from chapter 3...',
                      icon: Icons.description_outlined,
                      maxLines: 4,
                    ),
                    SizedBox(height: 20.h),
                    _buildSectionTitle('Submission Deadline'),
                    SizedBox(height: 12.h),
                    _buildDatePicker(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: _buildUploadButton(service),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF64748B), letterSpacing: 0.5),
    );
  }
  Widget _buildClassDropdown(List<String> assignedClasses) {
    if (assignedClasses.isEmpty) return const Text('No classes assigned');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: _selectedClass ?? (assignedClasses.isNotEmpty ? assignedClasses.first : null),
          decoration: const InputDecoration(border: InputBorder.none),
          items: assignedClasses.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.outfit()))).toList(),
          onChanged: (val) => setState(() => _selectedClass = val),
        ),
      ),
    );
  }
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.outfit(),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF6366F1), size: 20.sp),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
        labelStyle: GoogleFonts.outfit(color: const Color(0xFF64748B)),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Please enter $label' : null,
    );
  }
  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: const Color(0xFF6366F1), size: 20.sp),
            SizedBox(width: 12.w),
            Text(DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate), style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('Change', style: GoogleFonts.outfit(color: const Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 12.sp)),
          ],
        ),
      ),
    );
  }
  Widget _buildUploadButton(TeacherFirestoreService service) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: _isUploading ? null : () => _upload(service),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          elevation: 0,
        ),
        child: _isUploading
            ? SizedBox(height: 24.h, width: 24.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
            : Text('Assign to Students', style: GoogleFonts.outfit(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
  Future<void> _upload(TeacherFirestoreService service) async {
    if (!_formKey.currentState!.validate()) return;
    final teacher = context.read<TeacherAuthProvider>().currentTeacher;
    final defaultClass = teacher?.assignedClasses.isNotEmpty == true ? teacher!.assignedClasses.first : 'Unknown';
    setState(() => _isUploading = true);
    try {
      await service.uploadHomework(
        className: _selectedClass ?? defaultClass,
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _selectedDate,
        teacherId: teacher?.id ?? 'T-ID',
        teacherName: teacher?.name ?? 'Teacher',
        subject: teacher?.subject ?? 'General',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Homework assigned to ${_selectedClass ?? defaultClass}!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }
}