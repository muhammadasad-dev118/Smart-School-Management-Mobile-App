import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_school_unified/core/constants/app_constants.dart';
import 'package:smart_school_unified/services/firebase/teacher_firestore_service.dart';
import 'package:smart_school_unified/modules/teacher/providers/auth_provider.dart';
import 'package:provider/provider.dart';
class NoticeUploadScreen extends StatefulWidget {
  const NoticeUploadScreen({super.key});
  @override
  State<NoticeUploadScreen> createState() => _NoticeUploadScreenState();
}
class _NoticeUploadScreenState extends State<NoticeUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = 'Class';
  String _selectedClass = '';
  bool _isSending = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<TeacherAuthProvider>();
      if (auth.currentTeacher != null && auth.currentTeacher!.assignedClasses.isNotEmpty) {
        setState(() {
          _selectedClass = auth.currentTeacher!.assignedClasses.first;
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final service = Provider.of<TeacherFirestoreService>(context);
    final authProvider = Provider.of<TeacherAuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Class Notice'),
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategoryDropdown(),
              if (_selectedCategory == 'Class') ...[
                const SizedBox(height: 20),
                _buildClassDropdown(authProvider.currentTeacher?.assignedClasses ?? []),
              ],
              const SizedBox(height: 20),
              _buildTextField(_titleController, 'Title', 'Enter notice title'),
              const SizedBox(height: 20),
              _buildTextField(_contentController, 'Content', 'Enter notice content...', maxLines: 5),
              const SizedBox(height: 40),
              _buildSendButton(service, authProvider),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: ['Class', 'General']
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (val) => setState(() => _selectedCategory = val!),
        ),
      ],
    );
  }
  Widget _buildClassDropdown(List<String> assignedClasses) {
    if (assignedClasses.isEmpty) {
      return Text('No classes assigned', style: GoogleFonts.outfit(color: Colors.red));
    }
    if (!assignedClasses.contains(_selectedClass)) {
      _selectedClass = assignedClasses.first;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Class', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedClass,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: assignedClasses
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (val) => setState(() => _selectedClass = val!),
        ),
      ],
    );
  }
  Widget _buildTextField(TextEditingController controller, String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }
  Widget _buildSendButton(TeacherFirestoreService service, TeacherAuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSending ? null : () => _send(service, authProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isSending
            ? const CircularProgressIndicator(color: Colors.white)
            : Text('Send Notice', style: GoogleFonts.outfit(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
  Future<void> _send(TeacherFirestoreService service, TeacherAuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);
    try {
      await service.sendNotice(
        title: _titleController.text,
        content: _contentController.text,
        category: _selectedCategory,
        teacherName: authProvider.currentTeacher?.name ?? 'Teacher',
        teacherId: authProvider.currentTeacher?.id ?? 'unknown',
        className: _selectedCategory == 'Class' ? _selectedClass : null,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notice sent successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }
}