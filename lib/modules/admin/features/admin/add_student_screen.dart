import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_school_unified/core/theme/app_theme.dart';
import 'package:smart_school_unified/core/constants/app_constants.dart';
import 'package:smart_school_unified/models/student_model.dart';
import 'package:smart_school_unified/modules/admin/providers/student_provider.dart';
import 'package:smart_school_unified/services/auth/auth_service.dart';
class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});
  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}
class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  StudentModel? _editStudent;
  final _nameCtrl = TextEditingController();
  final _rollCtrl = TextEditingController();
  final _guardianNameCtrl = TextEditingController();
  final _guardianRelCtrl = TextEditingController();
  final _guardianPhoneCtrl = TextEditingController();
  final _guardianEmailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _selectedClass = AppConstants.classes.first;
  String _selectedSection = AppConstants.sections.first;
  String _selectedGender = 'Male';
  DateTime _dob = DateTime(2010, 1, 1);
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is StudentModel && _editStudent == null) {
      _editStudent = args;
      _nameCtrl.text = args.name;
      _rollCtrl.text = args.rollNumber;
      _selectedClass = args.className;
      _selectedSection = args.section;
      _selectedGender = args.gender;
      _dob = args.dateOfBirth;
      _guardianNameCtrl.text = args.guardianName;
      _guardianRelCtrl.text = args.guardianRelation;
      _guardianPhoneCtrl.text = args.guardianPhone;
      _guardianEmailCtrl.text = args.guardianEmail;
      _addressCtrl.text = args.address;
      _cityCtrl.text = args.city;
      _stateCtrl.text = args.state;
      _zipCtrl.text = args.zipCode;
      _emailCtrl.text = args.email;
      _passwordCtrl.text = args.password;
    }
  }
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final student = StudentModel(
        id: _editStudent?.id ?? '',
        name: _nameCtrl.text.trim(),
        className: _selectedClass,
        section: _selectedSection,
        rollNumber: _rollCtrl.text.trim(),
        gender: _selectedGender,
        dateOfBirth: _dob,
        guardianName: _guardianNameCtrl.text.trim(),
        guardianRelation: _guardianRelCtrl.text.trim(),
        guardianPhone: _guardianPhoneCtrl.text.trim(),
        guardianEmail: _guardianEmailCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        zipCode: _zipCtrl.text.trim(),
        email: _emailCtrl.text.trim().toLowerCase(),
        password: _passwordCtrl.text.trim(),
        enrolledAt: _editStudent?.enrolledAt ?? DateTime.now(),
      );
      final provider = context.read<StudentProvider>();
      if (_editStudent != null) {
        await provider.updateStudent(_editStudent!.id, student.toMap());
      } else {
        final authService = AuthService();
        final userCredential = await authService.createAccount(student.email, student.password);
        final uid = userCredential.user!.uid;
        await provider.addStudent(student, docId: uid);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
    setState(() => _isLoading = false);
  }
  @override
  void dispose() {
    _nameCtrl.dispose(); _rollCtrl.dispose();
    _guardianNameCtrl.dispose(); _guardianRelCtrl.dispose();
    _guardianPhoneCtrl.dispose(); _guardianEmailCtrl.dispose();
    _addressCtrl.dispose(); _cityCtrl.dispose();
    _stateCtrl.dispose(); _zipCtrl.dispose();
    _emailCtrl.dispose(); _passwordCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final isEdit = _editStudent != null;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Edit Student' : 'Enroll New Student',
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: TextButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                ? SizedBox(width: 20.w, height: 20.w, child: const CircularProgressIndicator(strokeWidth: 2))
                : Text('Save', style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPhotoPicker(),
              SizedBox(height: 32.h),
              _buildSectionTitle('Basic Information'),
              SizedBox(height: 20.h),
              _buildFieldLabel('Full Name'),
              _buildTextField(_nameCtrl, 'e.g. John Doe', Icons.person_outline),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Class'),
                        _buildDropdown(_selectedClass, AppConstants.classes, (v) => setState(() => _selectedClass = v!)),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Section'),
                        _buildDropdown(_selectedSection, AppConstants.sections, (v) => setState(() => _selectedSection = v!)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              _buildFieldLabel('Roll Number'),
              _buildTextField(_rollCtrl, 'e.g. 101', Icons.numbers_rounded),
              SizedBox(height: 20.h),
              _buildFieldLabel('Date of Birth'),
              _buildDatePicker(),
              SizedBox(height: 32.h),
              _buildSectionTitle('Login Credentials'),
              SizedBox(height: 20.h),
              _buildFieldLabel('Login Email'),
              _buildTextField(_emailCtrl, 'student@school.com', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              SizedBox(height: 20.h),
              _buildFieldLabel('Login Password'),
              _buildTextField(_passwordCtrl, '••••••••', Icons.lock_outline, isPassword: true),
              SizedBox(height: 32.h),
              _buildSectionTitle('Guardian Details'),
              SizedBox(height: 20.h),
              _buildFieldLabel('Guardian Name'),
              _buildTextField(_guardianNameCtrl, 'Father/Mother Name', Icons.people_outline),
              SizedBox(height: 20.h),
              _buildFieldLabel('Phone Number'),
              _buildTextField(_guardianPhoneCtrl, '+1 234 567 890', Icons.phone_outlined, keyboardType: TextInputType.phone),
              SizedBox(height: 32.h),
              _buildSectionTitle('Address'),
              SizedBox(height: 20.h),
              _buildTextField(_addressCtrl, 'Street Address', Icons.location_on_outlined),
              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
      bottomSheet: _buildBottomActions(),
    );
  }
  Widget _buildPhotoPicker() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 100.r,
            height: 100.r,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, size: 50.sp, color: Colors.grey[400]),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: const BoxDecoration(
                color: AppTheme.primaryIndigo,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.camera_alt_rounded, size: 16.sp, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryIndigo,
      ),
    );
  }
  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }
  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {TextInputType? keyboardType, bool isPassword = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      obscureText: isPassword ? _obscurePassword : false,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20.sp),
        suffixIcon: isPassword ? IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20.sp),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ) : null,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Required';
        if (isPassword && v.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }
  Widget _buildDropdown(String value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: _dob,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (d != null) setState(() => _dob = d);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_outlined, size: 20.sp, color: Colors.grey[600]),
            SizedBox(width: 12.w),
            Text(
              '${_dob.day}/${_dob.month}/${_dob.year}',
              style: GoogleFonts.outfit(fontSize: 14.sp, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text('Cancel', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryIndigo,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text(
                _editStudent != null ? 'Update' : 'Enroll Student',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}