import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_school_unified/core/constants/app_constants.dart';
import 'package:smart_school_unified/models/teacher_student_models.dart';
import 'package:smart_school_unified/services/firebase/teacher_firestore_service.dart';
import 'package:smart_school_unified/modules/teacher/providers/auth_provider.dart';
import 'package:provider/provider.dart';
class AttendanceScreen extends StatefulWidget {
  final String className;
  const AttendanceScreen({super.key, required this.className});
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}
class _AttendanceScreenState extends State<AttendanceScreen> {
  final Map<String, bool> _attendance = {};
  bool _isSaving = false;
  bool _isLoadingExisting = true;
  DateTime _selectedDate = DateTime.now();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingAttendance();
    });
  }
  Future<void> _loadExistingAttendance() async {
    setState(() => _isLoadingExisting = true);
    final service = Provider.of<TeacherFirestoreService>(context, listen: false);
    final teacher = Provider.of<TeacherAuthProvider>(context, listen: false).currentTeacher;
    final teacherId = teacher?.id ?? 'Unknown';
    final subject = teacher?.subject ?? 'General';
    try {
      final existingData = await service.getAttendance(
        className: widget.className,
        date: _selectedDate,
        teacherId: teacherId,
        subject: subject,
      );
      if (mounted) {
        setState(() {
          if (existingData != null) {
            _attendance.clear();
            _attendance.addAll(existingData);
          } else {
            _attendance.clear();
          }
          _isLoadingExisting = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingExisting = false);
      debugPrint("Error loading attendance: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    final service = Provider.of<TeacherFirestoreService>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          'Mark Attendance',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16.w, top: 8.h, bottom: 8.h),
            child: TextButton.icon(
              onPressed: () => _selectDate(context),
              icon: Icon(Icons.calendar_today_rounded, size: 16.sp),
              label: Text(
                DateFormat('MMM dd').format(_selectedDate),
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.1),
                foregroundColor: AppConstants.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryHeader(),
          Expanded(
            child: _isLoadingExisting
              ? const Center(child: CircularProgressIndicator())
              : StreamBuilder<List<TeacherModuleStudentModel>>(
                  stream: service.getStudentsByClass(widget.className),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final students = snapshot.data ?? [];
                    if (students.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.group_off_rounded, size: 64.sp, color: Colors.grey[300]),
                            SizedBox(height: 16.h),
                            Text(
                              'No students found in ${widget.className}',
                              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16.sp),
                            ),
                          ],
                        ),
                      );
                    }
                    for (var student in students) {
                      if (!_attendance.containsKey(student.id)) {
                        _attendance[student.id] = true;
                      }
                    }
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        return _buildStudentCard(students[index]);
                      },
                    );
                  },
                ),
          ),
          if (!_isLoadingExisting && _attendance.isNotEmpty && _selectedDate.day == DateTime.now().day)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Attendance already marked for today',
                      style: GoogleFonts.outfit(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
            ),
          _buildSubmitButton(service),
        ],
      ),
    );
  }
  Widget _buildSummaryHeader() {
    int presentCount = _attendance.values.where((v) => v).length;
    int absentCount = _attendance.length - presentCount;
    return Container(
      padding: EdgeInsets.all(20.w),
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total', _attendance.length.toString(), Colors.white),
          _buildSummaryItem('Present', presentCount.toString(), Colors.greenAccent),
          _buildSummaryItem('Absent', absentCount.toString(), Colors.redAccent),
        ],
      ),
    );
  }
  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 24.sp, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: GoogleFonts.outfit(fontSize: 12.sp, color: Colors.white60)),
      ],
    );
  }
  Widget _buildStudentCard(TeacherModuleStudentModel student) {
    bool isPresent = _attendance[student.id] ?? true;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
          CircleAvatar(
            radius: 24.r,
            backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.1),
            child: Text(
              student.rollNumber,
              style: GoogleFonts.outfit(color: AppConstants.primaryColor, fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                ),
                Text('Roll No: ${student.rollNumber}', style: GoogleFonts.outfit(fontSize: 12.sp, color: Colors.grey)),
              ],
            ),
          ),
          Row(
            children: [
              _buildStatusButton(student.id, true, isPresent),
              SizedBox(width: 8.w),
              _buildStatusButton(student.id, false, !isPresent),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildStatusButton(String studentId, bool status, bool isSelected) {
    Color activeColor = status ? Colors.green : Colors.red;
    return GestureDetector(
      onTap: () {
        setState(() {
          _attendance[studentId] = status;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          status ? 'P' : 'A',
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.white : Colors.grey[400],
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
  Widget _buildSubmitButton(TeacherFirestoreService service) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: _isSaving ? null : () => _saveAttendance(service),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            elevation: 0,
          ),
          child: _isSaving
              ? SizedBox(height: 24.h, width: 24.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(
                  _attendance.isNotEmpty && !_isLoadingExisting ? 'Update Attendance' : 'Submit Attendance',
                  style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.bold)
                ),
        ),
      ),
    );
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppConstants.primaryColor,
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadExistingAttendance();
    }
  }
  Future<void> _saveAttendance(TeacherFirestoreService service) async {
    setState(() => _isSaving = true);
    final teacher = Provider.of<TeacherAuthProvider>(context, listen: false).currentTeacher;
    final teacherId = teacher?.id ?? 'Unknown';
    final teacherName = teacher?.name ?? 'Teacher';
    final subject = teacher?.subject ?? 'General';
    try {
      await service.markAttendance(
        className: widget.className,
        date: _selectedDate,
        teacherId: teacherId,
        teacherName: teacherName,
        subject: subject,
        attendanceData: _attendance,
      );
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: const Icon(Icons.check_circle, color: Colors.green, size: 64),
          content: Text(
            'Attendance for ${widget.className} has been marked successfully!',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 16.sp),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('Done', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppConstants.primaryColor)),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}