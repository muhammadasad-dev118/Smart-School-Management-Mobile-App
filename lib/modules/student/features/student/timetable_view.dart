import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_school_unified/modules/student/providers/auth_provider.dart';
import 'package:smart_school_unified/modules/student/features/student/models/student_model.dart';
class StudentTimetableView extends StatefulWidget {
  const StudentTimetableView({super.key});
  @override
  State<StudentTimetableView> createState() => _StudentTimetableViewState();
}
class _StudentTimetableViewState extends State<StudentTimetableView> {
  final List<String> _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];
  late String _selectedDay;
  @override
  void initState() {
    super.initState();
    final weekday = DateTime.now().weekday;
    _selectedDay = _days[(weekday <= 6 ? weekday - 1 : 0)];
  }
  @override
  Widget build(BuildContext context) {
    final StudentModuleStudentModel? student = context.watch<StudentAuthProvider>().currentStudent;
    if (student == null) {
      return const Scaffold(body: Center(child: Text('Not logged in.')));
    }
    final className = student.className;
    final section   = student.section;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text('My Timetable',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1C1E),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('timetables')
            .where('className', isEqualTo: className)
            .where('section',   isEqualTo: section)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No timetable available yet',
                      style: GoogleFonts.outfit(
                          fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text("Your admin hasn't added any classes yet.",
                      style: GoogleFonts.outfit(
                          fontSize: 14, color: Colors.grey[400])),
                ],
              ),
            );
          }
          final allEntries = docs
              .map((d) => d.data() as Map<String, dynamic>)
              .toList();
          final dayEntries = allEntries
              .where((e) => (e['day'] ?? '') == _selectedDay)
              .toList()
            ..sort((a, b) =>
                (a['startTime'] ?? '').compareTo(b['startTime'] ?? ''));
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.school_rounded,
                        color: Colors.white, size: 32),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Class $className - $section',
                            style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        Text('${dayEntries.length} periods on $_selectedDay',
                            style: GoogleFonts.outfit(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _days.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final day = _days[i];
                    final isSelected = day == _selectedDay;
                    final count = allEntries
                        .where((e) => e['day'] == day)
                        .length;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDay = day),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF4F46E5)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF4F46E5)
                                  : Colors.grey.shade300),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                      color: const Color(0xFF4F46E5)
                                          .withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2))
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(day.substring(0, 3),
                                style: GoogleFonts.outfit(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[700],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                            if (count > 0) ...[
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.3)
                                      : const Color(0xFF4F46E5)
                                          .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('$count',
                                    style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF4F46E5),
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              if (dayEntries.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.free_breakfast_rounded,
                            size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('No classes on $_selectedDay',
                            style: GoogleFonts.outfit(
                                color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    itemCount: dayEntries.length,
                    itemBuilder: (context, index) {
                      final entry    = dayEntries[index];
                      final periodNo = index + 1;
                      final subject   = entry['subject']     ?? 'Subject';
                      final teacher   = entry['teacherName'] ?? 'N/A';
                      final room      = entry['room']        ?? 'N/A';
                      final startTime = entry['startTime']   ?? '--:--';
                      final endTime   = entry['endTime']     ?? '--:--';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                width: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4F46E5),
                                  borderRadius: const BorderRadius.only(
                                    topLeft:    Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('P',
                                        style: GoogleFonts.outfit(
                                            color: Colors.white70,
                                            fontSize: 11)),
                                    Text('$periodNo',
                                        style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(subject,
                                          style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Row(children: [
                                        const Icon(Icons.access_time_rounded,
                                            size: 13,
                                            color: Color(0xFF4F46E5)),
                                        const SizedBox(width: 4),
                                        Text('$startTime - $endTime',
                                            style: GoogleFonts.outfit(
                                                color: const Color(0xFF4F46E5),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600)),
                                      ]),
                                      const SizedBox(height: 4),
                                      Row(children: [
                                        const Icon(Icons.person_outline,
                                            size: 13, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(teacher,
                                              style: GoogleFonts.outfit(
                                                  color: Colors.grey[600],
                                                  fontSize: 12),
                                              overflow:
                                                  TextOverflow.ellipsis),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                            Icons.meeting_room_outlined,
                                            size: 13,
                                            color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text('Room $room',
                                            style: GoogleFonts.outfit(
                                                color: Colors.grey[600],
                                                fontSize: 12)),
                                      ]),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}