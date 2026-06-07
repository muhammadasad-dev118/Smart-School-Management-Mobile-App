import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smart_school_unified/firebase_options.dart';
import 'package:smart_school_unified/services/auth/auth_provider.dart';
import 'package:smart_school_unified/auth/login_screen.dart';
import 'modules/admin/providers/dashboard_provider.dart';
import 'modules/admin/providers/student_provider.dart';
import 'modules/admin/providers/fee_provider.dart';
import 'modules/admin/providers/notice_provider.dart';
import 'modules/admin/providers/admin_auth_provider.dart';
import 'modules/admin/providers/timetable_provider.dart';
import 'modules/admin/providers/notification_provider.dart';
import 'package:smart_school_unified/auth/forgot_password_screen.dart';
import 'modules/admin/features/admin/dashboard_screen.dart';
import 'modules/admin/features/admin/add_student_screen.dart';
import 'modules/admin/features/admin/teacher_management.dart';
import 'modules/admin/features/admin/send_teacher_notification_screen.dart';
import 'modules/admin/features/admin/notice_screen.dart';
import 'modules/admin/features/admin/fees_screen.dart';
import 'modules/teacher/providers/auth_provider.dart' as teacher_auth;
import 'modules/teacher/providers/notification_provider.dart' as teacher_notification;
import 'modules/teacher/providers/timetable_provider.dart' as teacher_timetable;
import 'modules/teacher/features/dashboard/teacher_dashboard_screen.dart';
import 'modules/teacher/features/attendance/attendance_class_selection_screen.dart';
import 'modules/teacher/features/timetable/teacher_timetable_screen.dart';
import 'modules/teacher/features/notice/notice_view_screen.dart';
import 'modules/teacher/features/class_management/class_management_screens.dart';
import 'package:smart_school_unified/services/firebase/teacher_firestore_service.dart';
import 'package:smart_school_unified/modules/student/providers/auth_provider.dart' as student_auth;
import 'package:smart_school_unified/modules/student/features/student/providers/homework_provider.dart' as student_homework;
import 'package:smart_school_unified/modules/student/features/student/providers/timetable_provider.dart' as student_timetable;
import 'package:smart_school_unified/modules/student/features/student/student_dashboard_screen.dart';
import 'package:smart_school_unified/modules/student/features/student/attendance_view.dart';
import 'package:smart_school_unified/modules/student/features/student/homework_view.dart';
import 'package:smart_school_unified/modules/student/features/student/notice_screen.dart' as student_notice;
import 'package:smart_school_unified/modules/student/features/student/marks_view.dart';
import 'package:smart_school_unified/modules/student/features/student/timetable_view.dart';
import 'package:smart_school_unified/modules/student/features/student/notification_screen.dart' as student_notification_view;
import 'package:smart_school_unified/services/firebase/student_firestore_service.dart';
import 'package:smart_school_unified/services/firebase/firestore_service.dart';
import 'package:smart_school_unified/services/notifications/notification_provider.dart';
import 'package:smart_school_unified/services/theme/theme_provider.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppNotificationProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => FeeProvider()),
        ChangeNotifierProvider(create: (_) => NoticeProvider()),
        ChangeNotifierProvider(create: (_) => AdminAuthProvider()),
        ChangeNotifierProvider(create: (_) => TimetableProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        Provider<TeacherFirestoreService>(create: (_) => TeacherFirestoreService()),
        ChangeNotifierProvider(create: (_) => teacher_auth.TeacherAuthProvider()),
        ChangeNotifierProvider(create: (_) => teacher_notification.TeacherNotificationProvider()),
        ChangeNotifierProvider(create: (_) => teacher_timetable.TimetableProvider()),
        Provider<StudentFirestoreService>(create: (_) => StudentFirestoreService()),
        ChangeNotifierProvider(create: (_) => student_auth.StudentAuthProvider()),
        ChangeNotifierProvider(create: (_) => student_homework.StudentHomeworkProvider()),
        ChangeNotifierProvider(create: (_) => student_timetable.TimetableProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const SmartSchoolApp(),
    ),
  );
}
class SmartSchoolApp extends StatelessWidget {
  const SmartSchoolApp({super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ScreenUtilInit(
          designSize: constraints.maxWidth > 600 ? const Size(1280, 800) : const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              title: 'Smart School Management System',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.indigo,
                useMaterial3: true,
                visualDensity: VisualDensity.adaptivePlatformDensity,
                brightness: Brightness.light,
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                primarySwatch: Colors.indigo,
                useMaterial3: true,
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
              themeMode: context.watch<ThemeProvider>().themeMode,
              home: const AuthWrapper(),
              routes: {
                '/login': (context) => const LoginScreen(),
                '/forgot-password': (context) => const ForgotPasswordScreen(),
                '/admin-dashboard': (context) => const AdminDashboardScreen(),
                '/add-student': (context) => const AddStudentScreen(),
                '/add-teacher': (context) => const AddTeacherScreen(),
                '/send-teacher-notification': (context) => const SendTeacherNotificationScreen(),
                '/notice': (context) => const NoticeScreen(),
                '/fees': (context) => const FeesScreen(),
                '/teacher-dashboard': (context) => TeacherDashboardScreen(),
                '/teacher-attendance': (context) => const AttendanceClassSelectionScreen(actionType: 'Attendance'),
                '/teacher-timetable': (context) => const TeacherTimetableScreen(),
                '/teacher-notices': (context) => const NoticeViewScreen(),
                '/teacher-classes': (context) => const ClassListScreen(),
                '/student-dashboard': (context) => StudentDashboardScreen(),
                '/attendance': (context) => const AttendanceView(),
                '/homework': (context) => const HomeworkView(),
                '/student-notices': (context) => const student_notice.NoticeScreen(),
                '/marks': (context) => const MarksView(),
                '/student-timetable': (context) => const StudentTimetableView(),
                '/student-notifications': (context) => const student_notification_view.NotificationScreen(),
              },
            );
          },
        );
      },
    );
  }
}
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.isAuthenticated) {
      final role = authProvider.user?.role;
      switch (role) {
        case 'admin':
          return const AdminDashboardScreen();
        case 'teacher':
          return Consumer<teacher_auth.TeacherAuthProvider>(
            builder: (context, teacherAuth, _) {
              if (teacherAuth.currentTeacher != null && teacherAuth.currentTeacher!.id != authProvider.user!.uid) {
                teacherAuth.logout();
              }
              if (teacherAuth.currentTeacher == null) {
                teacherAuth.setTeacherById(authProvider.user!.uid, email: authProvider.user!.email);
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              return TeacherDashboardScreen();
            },
          );
        case 'student':
          return Consumer<student_auth.StudentAuthProvider>(
            builder: (context, studentAuth, _) {
              if (studentAuth.currentStudent != null && studentAuth.currentStudent!.id != authProvider.user!.uid) {
                studentAuth.logout();
              }
              if (studentAuth.currentStudent == null) {
                studentAuth.setStudentById(authProvider.user!.uid, email: authProvider.user!.email);
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              return StudentDashboardScreen();
            },
          );
        default:
          return const Scaffold(body: Center(child: Text('Unknown Role')));
      }
    } else {
      return const LoginScreen();
    }
  }
}