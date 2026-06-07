import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_school_unified/services/auth/logout_service.dart';
import 'package:smart_school_unified/services/firebase/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_school_unified/services/theme/theme_provider.dart';
import 'package:provider/provider.dart';
class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});
  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}
class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  Map<String, dynamic> _schoolConfig = {};
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  Future<void> _loadSettings() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final config = await _firestoreService.getSchoolConfig();
    if (!mounted) return;
    setState(() {
      _schoolConfig = config;
      _isLoading = false;
    });
  }
  void _showSchoolProfileDialog() {
    final nameController = TextEditingController(text: _schoolConfig['schoolName']);
    final taglineController = TextEditingController(text: _schoolConfig['tagline']);
    final addressController = TextEditingController(text: _schoolConfig['address']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit School Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, 'School Name', Icons.school),
              SizedBox(height: 16.h),
              _buildTextField(taglineController, 'Tagline', Icons.label_important_outline),
              SizedBox(height: 16.h),
              _buildTextField(addressController, 'Address', Icons.location_on_outlined),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newConfig = {
                'schoolName': nameController.text,
                'tagline': taglineController.text,
                'address': addressController.text,
              };
              await _firestoreService.updateSchoolConfig(newConfig);
              if (!context.mounted) return;
              Navigator.of(context).pop();
              _loadSettings();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings updated successfully!')),
              );
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
  void _showChangePasswordDialog() {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('A password reset link will be sent to your registered email:\n\n$email'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                if (!context.mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reset link sent! Check your email.')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }
  void _showAcademicSessionDialog() {
    final yearController = TextEditingController(text: _schoolConfig['academicYear'] ?? '2023-2024');
    String selectedSemester = _schoolConfig['semester'] ?? 'Spring';
    final semesters = ['Spring', 'Fall', 'Summer', 'Winter'];
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Academic Session', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(yearController, 'Academic Year', Icons.calendar_month),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                value: selectedSemester,
                decoration: InputDecoration(
                  labelText: 'Semester',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                items: semesters.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setDialogState(() => selectedSemester = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (yearController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid year')));
                  return;
                }
                final newConfig = Map<String, dynamic>.from(_schoolConfig);
                newConfig['academicYear'] = yearController.text.trim();
                newConfig['semester'] = selectedSemester;
                await _firestoreService.updateSchoolConfig(newConfig);
                if (!context.mounted) return;
                Navigator.pop(context);
                _loadSettings();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session updated!')));
              },
              child: const Text('Update Session'),
            ),
          ],
        ),
      ),
    );
  }
  void _showAdminProfileDialog() {
    final user = FirebaseAuth.instance.currentUser;
    final nameController = TextEditingController(text: user?.displayName ?? 'Admin');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Admin Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(nameController, 'Display Name', Icons.person_outline),
            SizedBox(height: 8.h),
            Text(
              'Email: ${user?.email}',
              style: GoogleFonts.outfit(fontSize: 12.sp, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await user?.updateDisplayName(nameController.text);
              if (!context.mounted) return;
              Navigator.pop(context);
              _loadSettings();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated!')));
            },
            child: const Text('Save Profile'),
          ),
        ],
      ),
    );
  }
  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }
  void _showNotificationsDialog() {
    bool pushEnabled = _schoolConfig['pushNotifications'] ?? true;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Notifications', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive alerts for new notices and fees'),
            value: pushEnabled,
            onChanged: (val) => setDialogState(() => pushEnabled = val),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final newConfig = Map<String, dynamic>.from(_schoolConfig);
                newConfig['pushNotifications'] = pushEnabled;
                await _firestoreService.updateSchoolConfig(newConfig);
                if (!context.mounted) return;
                Navigator.pop(context);
                _loadSettings();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification settings updated!')));
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
  void _showThemeDialog() {
    String selectedTheme = _schoolConfig['theme'] ?? 'Light';
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Theme & Appearance', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Light', 'Dark', 'System Default'].map((t) => RadioListTile<String>(
              title: Text(t),
              value: t,
              groupValue: selectedTheme,
              onChanged: (val) => setDialogState(() => selectedTheme = val!),
            )).toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final newConfig = Map<String, dynamic>.from(_schoolConfig);
                newConfig['theme'] = selectedTheme;
                await context.read<ThemeProvider>().setTheme(selectedTheme);
                if (!context.mounted) return;
                Navigator.of(context).pop();
                _loadSettings();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Theme preference saved!')));
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(strokeWidth: 2))),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadSettings,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.r),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('General Settings'),
              SizedBox(height: 16.h),
              _buildSettingTile(
                context,
                icon: Icons.school_outlined,
                title: 'School Profile',
                subtitle: _schoolConfig['schoolName'] ?? 'Manage school name and branding',
                color: Colors.blue,
                onTap: _showSchoolProfileDialog,
              ),
              _buildSettingTile(
                context,
                icon: Icons.calendar_today_outlined,
                title: 'Academic Session',
                subtitle: 'Active: ${_schoolConfig['academicYear'] ?? '2023-2024'} (${_schoolConfig['semester'] ?? 'Spring'})',
                color: Colors.orange,
                onTap: _showAcademicSessionDialog,
              ),
              SizedBox(height: 32.h),
              _buildSectionHeader('Account & Security'),
              SizedBox(height: 16.h),
              _buildSettingTile(
                context,
                icon: Icons.person_outline_rounded,
                title: 'Admin Profile',
                subtitle: FirebaseAuth.instance.currentUser?.displayName ?? 'Update your display name',
                color: Colors.indigo,
                onTap: _showAdminProfileDialog,
              ),
              _buildSettingTile(
                context,
                icon: Icons.lock_outline_rounded,
                title: 'Change Password',
                subtitle: 'Request a reset link',
                color: Colors.red,
                onTap: _showChangePasswordDialog,
              ),
              SizedBox(height: 32.h),
              _buildSectionHeader('App Preferences'),
              SizedBox(height: 16.h),
              _buildSettingTile(
                context,
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                subtitle: (_schoolConfig['pushNotifications'] ?? true) ? 'Push alerts enabled' : 'Push alerts disabled',
                color: Colors.green,
                onTap: _showNotificationsDialog,
              ),
              _buildSettingTile(
                context,
                icon: Icons.color_lens_outlined,
                title: 'Theme & Appearance',
                subtitle: '${_schoolConfig['theme'] ?? 'Light'} Mode',
                color: Colors.purple,
                onTap: _showThemeDialog,
              ),
              SizedBox(height: 40.h),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => LogoutService.logout(context),
                  icon: const Icon(Icons.logout_rounded),
                  label: Text('Sign Out', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Center(
                child: Text(
                  'v1.0.4 - Premium Edition',
                  style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
        letterSpacing: 1,
      ),
    );
  }
  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.all(16.r),
        leading: Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: color, size: 24.sp),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Text(
            subtitle,
            style: GoogleFonts.outfit(fontSize: 13.sp, color: Colors.grey),
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16.sp, color: Colors.grey[400]),
      ),
    );
  }
}