import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_school_unified/core/theme/app_theme.dart';
import 'package:smart_school_unified/core/constants/app_constants.dart';
import 'package:smart_school_unified/models/student_model.dart';
import 'package:smart_school_unified/modules/admin/providers/student_provider.dart';
class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});
  @override
  State<StudentManagementScreen> createState() => _StudentManagementScreenState();
}
class _StudentManagementScreenState extends State<StudentManagementScreen> {
  String _selectedClass = 'All Classes';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().fetchStudents();
    });
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Students',
          style: GoogleFonts.outfit(color: Colors.black, fontSize: 24.sp, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryIndigo, size: 28.sp),
            onPressed: () => Navigator.pushNamed(context, '/add-student'),
          ),
          SizedBox(width: 16.w),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildClassFilter(),
          Expanded(
            child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildStudentList(provider.students),
          ),
        ],
      ),
    );
  }
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Search by name or roll number...',
          hintStyle: GoogleFonts.outfit(fontSize: 14.sp),
          prefixIcon: Icon(Icons.search_rounded, size: 20.sp, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16.h),
        ),
      ),
    );
  }
  Widget _buildClassFilter() {
    return Container(
      height: 40.h,
      margin: EdgeInsets.only(bottom: 16.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        itemCount: AppConstants.classes.length + 1,
        itemBuilder: (context, index) {
          final label = index == 0 ? 'All Classes' : AppConstants.classes[index - 1];
          final isSelected = _selectedClass == label;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedClass = label);
              context.read<StudentProvider>().fetchStudents(
                className: label == 'All Classes' ? null : label,
              );
            },
            child: Container(
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryIndigo : Colors.grey[50],
                borderRadius: BorderRadius.circular(20.r),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 13.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black54,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildStudentList(List<StudentModel> allStudents) {
    final students = allStudents.where((s) {
      if (_searchQuery.isEmpty) return true;
      return s.name.toLowerCase().contains(_searchQuery) ||
             s.rollNumber.toLowerCase().contains(_searchQuery);
    }).toList();
    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline_rounded, size: 64.sp, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text('No students found', style: GoogleFonts.outfit(fontSize: 16.sp, color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final s = students[index];
        return _buildStudentCard(s);
      },
    );
  }
  Widget _buildStudentCard(StudentModel s) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28.r,
                backgroundColor: AppTheme.primaryIndigo.withValues(alpha: 0.1),
                child: Text(
                  s.name[0].toUpperCase(),
                  style: GoogleFonts.outfit(color: AppTheme.primaryIndigo, fontWeight: FontWeight.bold, fontSize: 20.sp),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name, style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    Text('${s.className} - Section ${s.section}', style: GoogleFonts.outfit(fontSize: 12.sp, color: Colors.grey)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit_outlined, size: 20.sp, color: Colors.grey),
                onPressed: () => Navigator.pushNamed(context, '/add-student', arguments: s),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, size: 20.sp, color: Colors.red[300]),
                onPressed: () => _showDeleteDialog(s),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildInfoBadge(s.feeStatus.toUpperCase(), s.feeStatus == 'paid' ? Colors.green : Colors.orange),
              SizedBox(width: 8.w),
              _buildInfoBadge('Roll: ${s.rollNumber}', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildInfoBadge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
  void _showDeleteDialog(StudentModel student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text('Delete Student', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to remove ${student.name}?', style: GoogleFonts.outfit()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<StudentProvider>().deleteStudent(student.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}