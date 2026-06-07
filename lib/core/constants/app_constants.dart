import 'package:flutter/material.dart';
class AppConstants {
  AppConstants._();
  static const String appName = 'Smart School';
  static const String tagline = 'MANAGE. EDUCATE. EXCEL.';
  static const String poweredBy = 'POWERED BY SCHOLASTIC CURATOR';
  static const String usersCollection = 'users';
  static const String studentsCollection = 'students';
  static const String teachersCollection = 'teachers';
  static const String feesCollection = 'fees';
  static const String noticesCollection = 'notices';
  static const String attendanceCollection = 'attendance';
  static const String timetablesCollection = 'timetables';
  static const String timetableRequestsCollection = 'timetable_requests';
  static const String roleAdmin = 'admin';
  static const String roleTeacher = 'teacher';
  static const String roleStudent = 'student';
  static const List<String> classes = [
    'Class 5', 'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10',
  ];
  static const List<String> sections = ['A', 'B', 'C', 'D'];
  static const List<String> genders = ['Male', 'Female', 'Other'];
  static const String feesPaid = 'paid';
  static const String feesPending = 'pending';
  static const String feesOverdue = 'overdue';
  static const List<String> noticeCategories = [
    'All', 'Important', 'Academic', 'Events', 'General',
  ];
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1200;
  static const Color primaryColor = Color(0xFF4F46E5);
  static const Color accentColor = Color(0xFF6366F1);
  static const String homeworkCollection = 'homework';
  static const List<String> whitelistedEmails = [
    'muhmadasad106@gmail.com',
    'anwarali009.work.gmail.com@gmail.com',
  ];
}