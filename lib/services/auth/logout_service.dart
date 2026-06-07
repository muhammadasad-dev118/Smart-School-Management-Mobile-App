import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_school_unified/services/auth/auth_provider.dart';
import 'package:smart_school_unified/modules/teacher/providers/auth_provider.dart' as teacher_auth;
import 'package:smart_school_unified/modules/student/providers/auth_provider.dart' as student_auth;
import 'package:smart_school_unified/services/notifications/notification_provider.dart';
import 'package:smart_school_unified/modules/admin/providers/dashboard_provider.dart';
import 'package:smart_school_unified/modules/admin/providers/student_provider.dart';
class LogoutService {
  static Future<void> logout(BuildContext context) async {
    try {
      context.read<teacher_auth.TeacherAuthProvider>().logout();
    } catch (_) {}
    try {
      context.read<student_auth.StudentAuthProvider>().logout();
    } catch (_) {}
    try {
      context.read<AppNotificationProvider>().clear();
    } catch (_) {}
    try {
      context.read<DashboardProvider>().clear();
    } catch (_) {}
    try {
      context.read<StudentProvider>().clear();
    } catch (_) {}
    await context.read<AuthProvider>().logout();
    if (context.mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }
}