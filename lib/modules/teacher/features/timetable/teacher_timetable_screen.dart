import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_school_unified/modules/teacher/providers/timetable_provider.dart';
import 'package:smart_school_unified/modules/teacher/providers/auth_provider.dart';
import 'package:smart_school_unified/models/timetable_model.dart';
class TeacherTimetableScreen extends StatefulWidget {
  const TeacherTimetableScreen({super.key});
  @override
  State<TeacherTimetableScreen> createState() => _TeacherTimetableScreenState();
}
class _TeacherTimetableScreenState extends State<TeacherTimetableScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final teacher = context.read<TeacherAuthProvider>().currentTeacher;
      if (teacher != null) {
        context.read<TimetableProvider>().fetchTeacherTimetable(teacher.id);
        context.read<TimetableProvider>().fetchMyRequests(teacher.id);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        appBar: AppBar(
          title: Text('My Schedule', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1A1C1E),
          elevation: 0,
          bottom: TabBar(
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            indicatorColor: const Color(0xFF4F46E5),
            labelColor: const Color(0xFF4F46E5),
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'My Timetable'),
              Tab(text: 'My Requests'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTimetableTab(),
            _buildRequestsTab(),
          ],
        ),
      ),
    );
  }
  Widget _buildTimetableTab() {
    return Consumer<TimetableProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final entries = provider.teacherTimetable;
        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[300]),
                SizedBox(height: 16.h),
                Text('No classes assigned yet',
                    style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey)),
                SizedBox(height: 8.h),
                Text('The admin has not assigned any timetable yet.',
                    style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[400])),
              ],
            ),
          );
        }
        final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        return ListView(
          padding: EdgeInsets.all(16.r),
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_rounded, color: Colors.white, size: 32.sp),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Weekly Schedule',
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      Text('${entries.length} periods total',
                          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13.sp)),
                    ],
                  ),
                ],
              ),
            ),
            ...days.map((day) {
              final dayEntries = entries.where((e) => e.day == day).toList()
                ..sort((a, b) => a.startTime.compareTo(b.startTime));
              if (dayEntries.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 8.h, top: 8.h),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(day,
                        style: GoogleFonts.outfit(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                  ),
                  ...dayEntries.map((entry) => _buildPeriodCard(entry)),
                  SizedBox(height: 8.h),
                ],
              );
            }),
          ],
        );
      },
    );
  }
  Widget _buildPeriodCard(TimetableModel entry) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(entry.startTime,
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4F46E5),
                  fontSize: 12.sp)),
        ),
        title: Text('${entry.subject} — ${entry.className} ${entry.section}',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14.sp)),
        subtitle: Text('${entry.startTime} - ${entry.endTime} | Room: ${entry.room}',
            style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 12.sp)),
        trailing: IconButton(
          icon: Icon(Icons.swap_horiz_rounded, color: Colors.blue[600], size: 22.sp),
          tooltip: 'Request Change',
          onPressed: () => _showRequestDialog(entry),
        ),
      ),
    );
  }
  Widget _buildRequestsTab() {
    return Consumer<TimetableProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        if (provider.myRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
                SizedBox(height: 16.h),
                Text('No requests yet', style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey)),
                SizedBox(height: 8.h),
                Text('Use the swap button on any class to submit a request.',
                    style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[400]),
                    textAlign: TextAlign.center),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.all(16.r),
          itemCount: provider.myRequests.length,
          itemBuilder: (context, index) {
            final req = provider.myRequests[index];
            final statusColor = req.status == 'approved'
                ? Colors.green
                : req.status == 'rejected'
                    ? Colors.red
                    : Colors.orange;
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                title: Text(req.requestedSchedule,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                subtitle: Text('Reason: ${req.reason}',
                    style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 12.sp)),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(req.status.toUpperCase(),
                      style: GoogleFonts.outfit(
                          color: statusColor, fontWeight: FontWeight.bold, fontSize: 10.sp)),
                ),
              ),
            );
          },
        );
      },
    );
  }
  void _showRequestDialog(TimetableModel entry) {
    final reasonController = TextEditingController();
    final scheduleController = TextEditingController(
        text: '${entry.day} ${entry.startTime} - ${entry.endTime}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Request Schedule Change', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current: ${entry.day} ${entry.startTime} - ${entry.endTime}',
                style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: scheduleController,
              decoration: const InputDecoration(
                  labelText: 'Requested Schedule', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                  labelText: 'Reason for change', border: OutlineInputBorder()),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
            onPressed: () {
              final teacher = context.read<TeacherAuthProvider>().currentTeacher;
              if (teacher == null) return;
              final request = TimetableRequestModel(
                id: '',
                teacherId: teacher.id,
                teacherName: teacher.name,
                timetableId: entry.id,
                currentSchedule: '${entry.day} ${entry.startTime} - ${entry.endTime}',
                requestedSchedule: scheduleController.text,
                reason: reasonController.text,
                status: 'pending',
                createdAt: DateTime.now(),
              );
              context.read<TimetableProvider>().submitRequest(request);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Request submitted successfully!')),
              );
            },
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}