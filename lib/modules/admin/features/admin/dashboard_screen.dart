import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smart_school_unified/modules/admin/features/admin/student_management.dart';
import 'package:smart_school_unified/modules/admin/features/admin/teacher_management.dart';
import 'package:smart_school_unified/modules/admin/features/admin/notice_screen.dart';
import 'package:smart_school_unified/modules/admin/providers/dashboard_provider.dart';
import 'package:smart_school_unified/modules/admin/providers/notification_provider.dart';
import 'admin_notification_screen.dart';
import 'package:smart_school_unified/modules/admin/widgets/responsive.dart';
import 'package:smart_school_unified/core/constants/app_constants.dart';
import 'package:smart_school_unified/services/firebase/firestore_service.dart';
import 'package:smart_school_unified/services/auth/logout_service.dart';
import 'settings_screen.dart';
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}
class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardStats();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Responsive(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
      bottomNavigationBar: Responsive.isDesktop(context) ? null : _buildBottomNav(),
    );
  }
  Widget _buildTabletLayout() {
    return _buildDesktopLayout();
  }
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final bool isExtended = MediaQuery.of(context).size.width > AppConstants.desktopBreakpoint;
            return NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) => setState(() => _currentIndex = index),
              extended: isExtended,
              backgroundColor: Colors.white,
              selectedIconTheme: const IconThemeData(color: Color(0xFF4F46E5)),
              unselectedIconTheme: IconThemeData(color: Colors.grey[400]),
              selectedLabelTextStyle: GoogleFonts.outfit(
                color: const Color(0xFF4F46E5),
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelTextStyle: GoogleFonts.outfit(color: Colors.grey[500]),
              leading: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 8.w),
                child: isExtended
                  ? Row(
                      children: [
                        Image.asset('assets/images/logo.png', height: 40.h),
                        SizedBox(width: 8.w),
                        Text('Admin Panel', style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      ],
                    )
                  : Image.asset('assets/images/logo.png', height: 32.h),
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.grid_view_rounded), label: Text('Dashboard')),
                NavigationRailDestination(icon: Icon(Icons.people_outline_rounded), label: Text('Students')),
                NavigationRailDestination(icon: Icon(Icons.person_outline_rounded), label: Text('Teachers')),
                NavigationRailDestination(icon: Icon(Icons.campaign_outlined), label: Text('Announcements')),
                NavigationRailDestination(icon: Icon(Icons.settings_outlined), label: Text('Settings')),
              ],
            );
          },
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              const _DashboardContent(isDesktop: true),
              const StudentManagementScreen(),
              const TeacherManagementScreen(),
              const NoticeScreen(),
              const AdminSettingsScreen(),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildMobileLayout() {
    return IndexedStack(
      index: _currentIndex,
      children: [
        const _DashboardContent(isDesktop: false),
        const StudentManagementScreen(),
        const TeacherManagementScreen(),
        const NoticeScreen(),
        const AdminSettingsScreen(),
      ],
    );
  }
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4F46E5),
        unselectedItemColor: Colors.grey[400],
        showSelectedLabels: true,
        showUnselectedLabels: false,
        elevation: 0,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline_rounded), label: 'Students'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Teachers'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign_outlined), label: 'Announce'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}
class _DashboardContent extends StatelessWidget {
  final bool isDesktop;
  const _DashboardContent({required this.isDesktop});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () => provider.loadDashboardStats(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModernHeader(context),
              Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: isDesktop ? 1200.w : double.infinity),
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40.w : 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: isDesktop ? 40.h : 24.h),
                      Text(
                        'Overview',
                        style: GoogleFonts.outfit(
                          fontSize: isDesktop ? 24.sp : 20.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildModernStatsGrid(context, provider),
                      SizedBox(height: isDesktop ? 48.h : 32.h),
                      _buildQuickActions(context, provider),
                      SizedBox(height: isDesktop ? 48.h : 32.h),
                      _buildRecentActivity(context),
                      SizedBox(height: 48.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildModernHeader(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: context.read<FirestoreService>().schoolConfigStream(),
      builder: (context, snapshot) {
        final config = snapshot.data ?? {};
        final schoolName = (config['schoolName']?.toString().isEmpty ?? true)
            ? AppConstants.appName : config['schoolName'];
        final academicYear = (config['academicYear']?.toString().isEmpty ?? true)
            ? '2023-2024' : config['academicYear'];
        final semester = (config['semester']?.toString().isEmpty ?? true)
            ? 'Spring' : config['semester'];
        final session = '$academicYear ($semester)';
        return Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 20.h,
            bottom: isDesktop ? 60.h : 40.h,
            left: isDesktop ? 60.w : 24.w,
            right: isDesktop ? 60.w : 24.w
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6366F1), Color(0xFF4F46E5), Color(0xFF3730A3)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(isDesktop ? 48.r : 32.r),
              bottomRight: Radius.circular(isDesktop ? 48.r : 32.r),
            ),
          ),
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: isDesktop ? 1200.w : double.infinity),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Good Afternoon 🌤️',
                                style: GoogleFonts.outfit(fontSize: isDesktop ? 16.sp : 14.sp, color: Colors.white.withValues(alpha: 0.8)),
                              ),
                              SizedBox(width: 12.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Consumer<DashboardProvider>(
                                  builder: (context, provider, _) => Text(
                                    provider.currentTime,
                                    style: GoogleFonts.outfit(
                                      fontSize: isDesktop ? 14.sp : 12.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            schoolName,
                            style: GoogleFonts.outfit(fontSize: isDesktop ? 36.sp : 28.sp, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            'Session: $session',
                            style: GoogleFonts.outfit(fontSize: isDesktop ? 16.sp : 14.sp, color: Colors.white.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Consumer<NotificationProvider>(
                            builder: (context, notificationProvider, _) {
                              return _buildGlassIcon(
                                context,
                                Icons.notifications_none_rounded,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AdminNotificationScreen()),
                                ),
                              );
                            },
                          ),
                          SizedBox(width: 16.w),
                          _buildGlassIcon(
                            context,
                            Icons.person_outline_rounded,
                            label: 'AD',
                            onTap: () => LogoutService.logout(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: isDesktop ? 40.h : 32.h),
                  Container(
                    width: isDesktop ? 600.w : double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.7), size: 20.sp),
                        SizedBox(width: 12.w),
                        Text(
                          'Search students, teachers, classes...',
                          style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.7), fontSize: 15.sp),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
  Widget _buildGlassIcon(BuildContext context, IconData icon, {String? label, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 14.r : 10.r),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: label != null
            ? Text(label, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isDesktop ? 14.sp : 12.sp))
            : Icon(icon, color: Colors.white, size: isDesktop ? 24.sp : 22.sp),
      ),
    );
  }
  Widget _buildModernStatsGrid(BuildContext context, DashboardProvider provider) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: isDesktop ? 1.4 : 1.1,
      children: [
        _buildModernStatCard('Total Students', provider.stats['students']?.toString() ?? '0', Icons.school_rounded, const Color(0xFF6366F1)),
        _buildModernStatCard('Total Teachers', provider.stats['teachers']?.toString() ?? '0', Icons.person_rounded, const Color(0xFF10B981)),
        _buildModernStatCard('Classes', provider.stats['classes']?.toString() ?? '1', Icons.book_rounded, const Color(0xFF8B5CF6)),
        _buildModernStatCard('Active Users', provider.stats['activeUsers']?.toString() ?? '0', Icons.fact_check_rounded, const Color(0xFFF59E0B)),
      ],
    );
  }
  Widget _buildModernStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 8)),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 24.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.outfit(fontSize: 12.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
  Widget _buildQuickActions(BuildContext context, DashboardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 20.h),
        Wrap(
          spacing: 16.w,
          runSpacing: 16.h,
          children: [
            _buildActionChip(context, 'Add Student', Icons.person_add_rounded, const Color(0xFF4F46E5), '/add-student', provider),
            _buildActionChip(context, 'Add Teacher', Icons.group_add_rounded, const Color(0xFF10B981), '/add-teacher', provider),
            _buildActionChip(context, 'Post Notice', Icons.campaign_rounded, const Color(0xFFF59E0B), '/notice', provider),
            _buildActionChip(context, 'Fee Management', Icons.payments_rounded, const Color(0xFFF59E0B), '/fees', provider),
            _buildActionChip(context, 'Email Teacher', Icons.email_rounded, const Color(0xFF8B5CF6), '/send-teacher-notification', provider),
          ],
        ),
      ],
    );
  }
  Widget _buildActionChip(BuildContext context, String label, IconData icon, Color color, String route, DashboardProvider provider) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route).then((_) => provider.loadDashboardStats()),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18.sp),
              SizedBox(width: 10.w),
              Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13.sp)),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Activity', style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(width: 16.w),
              Text('View All', style: GoogleFonts.outfit(fontSize: 12.sp, color: const Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(40.r),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24.r)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_rounded, size: 48.sp, color: Colors.grey[200]),
              SizedBox(height: 16.h),
              Text(
                'No recent activities',
                style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 14.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }
}