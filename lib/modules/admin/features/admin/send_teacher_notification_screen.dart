import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smart_school_unified/services/firebase/firestore_service.dart';
import 'package:smart_school_unified/models/teacher_model.dart';
import 'package:smart_school_unified/models/student_model.dart';
import 'package:smart_school_unified/services/notifications/notification_provider.dart';
class SendTeacherNotificationScreen extends StatefulWidget {
  const SendTeacherNotificationScreen({super.key});
  @override
  State<SendTeacherNotificationScreen> createState() => _SendTeacherNotificationScreenState();
}
class _SendTeacherNotificationScreenState extends State<SendTeacherNotificationScreen> {
  final _messageController = TextEditingController();
  String _selectedRole = 'Teacher';
  String _selectedRecipientId = 'All';
  bool _isSending = false;
  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService>();
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Send Notification', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compose Notification',
              style: GoogleFonts.outfit(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              'Select a recipient and type your message to send an app and email notification.',
              style: GoogleFonts.outfit(fontSize: 14.sp, color: Colors.grey[500]),
            ),
            SizedBox(height: 32.h),
            _buildLabel('Select Recipient Type'),
            SizedBox(height: 12.h),
            Row(
              children: [
                _buildRoleOption('Teacher'),
                SizedBox(width: 16.w),
                _buildRoleOption('Student'),
              ],
            ),
            SizedBox(height: 24.h),
            _buildLabel('Select Recipient'),
            SizedBox(height: 12.h),
            _selectedRole == 'Teacher'
              ? _buildTeacherDropdown(firestoreService)
              : _buildStudentDropdown(firestoreService),
            SizedBox(height: 24.h),
            _buildLabel('Message'),
            SizedBox(height: 12.h),
            TextField(
              controller: _messageController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Type your message here...',
                hintStyle: GoogleFonts.outfit(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(color: Color(0xFF4F46E5)),
                ),
              ),
            ),
            SizedBox(height: 40.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendNotification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  elevation: 0,
                ),
                child: _isSending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded, color: Colors.white),
                          SizedBox(width: 12.w),
                          Text(
                            'Send Notification',
                            style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildRoleOption(String role) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = role;
            _selectedRecipientId = 'All';
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: isSelected ? const Color(0xFF4F46E5) : Colors.grey[200]!),
          ),
          child: Center(
            child: Text(
              role,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildTeacherDropdown(FirestoreService firestoreService) {
    return StreamBuilder<List<TeacherModel>>(
      stream: firestoreService.getTeachers(),
      builder: (context, snapshot) {
        final teachers = snapshot.data ?? [];
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedRecipientId,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              onChanged: (val) {
                setState(() {
                  _selectedRecipientId = val!;
                });
              },
              items: [
                const DropdownMenuItem(value: 'All', child: Text('All Teachers')),
                ...teachers.map((t) => DropdownMenuItem(
                  value: t.id,
                  child: Text('${t.name} (${t.subject})'),
                )),
              ],
            ),
          ),
        );
      }
    );
  }
  Widget _buildStudentDropdown(FirestoreService firestoreService) {
    return StreamBuilder<List<StudentModel>>(
      stream: firestoreService.getStudents(),
      builder: (context, snapshot) {
        final students = snapshot.data ?? [];
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedRecipientId,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              onChanged: (val) {
                setState(() {
                  _selectedRecipientId = val!;
                });
              },
              items: [
                const DropdownMenuItem(value: 'All', child: Text('All Students')),
                ...students.map((s) => DropdownMenuItem(
                  value: s.id,
                  child: Text('${s.name} (Class: ${s.className})'),
                )),
              ],
            ),
          ),
        );
      }
    );
  }
  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937)),
    );
  }
  Future<void> _sendNotification() async {
    if (_messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a message')));
      return;
    }
    setState(() => _isSending = true);
    try {
      final appNotificationProvider = context.read<AppNotificationProvider>();
      List<String> sentTo = ['admin'];
      if (_selectedRecipientId == 'All') {
        sentTo.add(_selectedRole.toLowerCase());
      } else {
        sentTo.add(_selectedRecipientId);
      }
      await appNotificationProvider.sendNotice(
        title: 'Admin Message',
        message: _messageController.text.trim(),
        sentTo: sentTo,
        category: 'Important',
        sentBy: 'School Admin',
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification sent successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }
}