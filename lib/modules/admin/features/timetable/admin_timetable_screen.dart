import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smart_school_unified/modules/admin/providers/timetable_provider.dart';
import 'package:smart_school_unified/models/timetable_model.dart';
import 'package:smart_school_unified/models/teacher_model.dart';
import 'package:smart_school_unified/services/firebase/firestore_service.dart';
import 'package:smart_school_unified/core/constants/app_constants.dart';
class AdminTimetableScreen extends StatefulWidget {
  const AdminTimetableScreen({super.key});
  @override
  State<AdminTimetableScreen> createState() => _AdminTimetableScreenState();
}
class _AdminTimetableScreenState extends State<AdminTimetableScreen> {
  String selectedClass = AppConstants.classes[0];
  String selectedSection = AppConstants.sections[0];
  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTimetable();
    });
  }
  void _loadTimetable() {
    context.read<TimetableProvider>().fetchTimetable(selectedClass, selectedSection);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Timetable Management', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_calls_rounded),
            tooltip: 'Change Requests',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TimetableRequestsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Consumer<TimetableProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildTimetableGrid(provider.timetables);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEntryDialog(null),
        label: const Text('Add Period'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF4F46E5),
      ),
    );
  }
  Widget _buildFilterBar() {
    return Container(
      padding: EdgeInsets.all(16.r),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedClass,
              decoration: const InputDecoration(labelText: 'Class', border: OutlineInputBorder()),
              items: AppConstants.classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => selectedClass = val);
                  _loadTimetable();
                }
              },
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedSection,
              decoration: const InputDecoration(labelText: 'Section', border: OutlineInputBorder()),
              items: AppConstants.sections.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => selectedSection = val);
                  _loadTimetable();
                }
              },
            ),
          ),
          SizedBox(width: 16.w),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: IconButton(
              icon: const Icon(Icons.copy_all_rounded, color: Color(0xFF4F46E5)),
              tooltip: 'Copy Monday to Tue-Thu',
              onPressed: () => _copyMondayToAllDays(),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _copyMondayToAllDays() async {
    final provider = context.read<TimetableProvider>();
    final mondayEntries = provider.timetables.where((e) => e.day == 'Monday').toList();
    if (mondayEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No periods found on Monday to copy!')));
      return;
    }
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Copy Timetable?'),
        content: const Text('This will copy all Monday periods to Tuesday, Wednesday, and Thursday.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, Copy', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copying periods... Please wait.')));
    int copied = 0;
    for (String targetDay in ['Tuesday', 'Wednesday', 'Thursday']) {
      for (var entry in mondayEntries) {
        bool exists = provider.timetables.any((e) =>
            e.day == targetDay && e.startTime == entry.startTime && e.room == entry.room);
        if (!exists) {
          final newEntry = TimetableModel(
            id: '',
            className: entry.className,
            section: entry.section,
            day: targetDay,
            subject: entry.subject,
            teacherId: entry.teacherId,
            teacherName: entry.teacherName,
            startTime: entry.startTime,
            endTime: entry.endTime,
            room: entry.room,
          );
          await provider.upsertTimetableEntry(newEntry);
          copied++;
        }
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied $copied new periods successfully!')));
      _loadTimetable();
    }
  }
  Widget _buildTimetableGrid(List<TimetableModel> entries) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No periods added yet', style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Tap "+ Add Period" to get started', style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[400])),
          ],
        ),
      );
    }
    final Map<String, List<TimetableModel>> byDay = {};
    for (final day in days) {
      byDay[day] = entries.where((e) => e.day == day).toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
    }
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: days.where((d) => byDay[d]!.isNotEmpty).map((day) {
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
              child: Text(day, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
            ),
            ...byDay[day]!.map((entry) => _buildPeriodCard(entry)),
            SizedBox(height: 8.h),
          ],
        );
      }).toList(),
    );
  }
  Widget _buildPeriodCard(TimetableModel entry) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.access_time_rounded, color: const Color(0xFF4F46E5), size: 22.sp),
        ),
        title: Text(entry.subject, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15.sp)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${entry.startTime} - ${entry.endTime}', style: GoogleFonts.outfit(color: const Color(0xFF4F46E5), fontSize: 12.sp, fontWeight: FontWeight.w600)),
            Text('Teacher: ${entry.teacherName}  |  Room: ${entry.room}', style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 12.sp)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_rounded, color: Colors.blue[600], size: 20.sp),
              tooltip: 'Edit',
              onPressed: () => _showEntryDialog(entry),
            ),
            IconButton(
              icon: Icon(Icons.delete_rounded, color: Colors.red[400], size: 20.sp),
              tooltip: 'Delete',
              onPressed: () => _confirmDelete(entry),
            ),
          ],
        ),
      ),
    );
  }
  void _confirmDelete(TimetableModel entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Period?'),
        content: Text('Are you sure you want to delete "${entry.subject}" on ${entry.day}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final error = await context.read<TimetableProvider>().deleteTimetableEntry(entry.id);
              if (error != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  void _showEntryDialog(TimetableModel? entry) {
    showDialog(
      context: context,
      builder: (context) => TimetableEntryDialog(
        entry: entry,
        className: selectedClass,
        section: selectedSection,
      ),
    ).then((_) => _loadTimetable());
  }
}
class TimetableEntryDialog extends StatefulWidget {
  final TimetableModel? entry;
  final String className;
  final String section;
  const TimetableEntryDialog({super.key, this.entry, required this.className, required this.section});
  @override
  State<TimetableEntryDialog> createState() => _TimetableEntryDialogState();
}
class _TimetableEntryDialogState extends State<TimetableEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  late String subject;
  late String day;
  late String teacherId;
  late String teacherName;
  late String startTime;
  late String endTime;
  late String room;
  int? selectedPeriodIndex;
  bool _isSaving = false;
  static const List<Map<String, String>> _periodSlots = [
    {'label': '1st Period',  'start': '08:00', 'end': '08:45'},
    {'label': '2nd Period',  'start': '08:45', 'end': '09:30'},
    {'label': '3rd Period',  'start': '09:45', 'end': '10:30'},
    {'label': '4th Period',  'start': '10:30', 'end': '11:15'},
    {'label': '5th Period',  'start': '11:30', 'end': '12:15'},
    {'label': '6th Period',  'start': '13:00', 'end': '13:45'},
    {'label': '7th Period',  'start': '13:45', 'end': '14:30'},
    {'label': '8th Period',  'start': '14:30', 'end': '15:15'},
  ];
  @override
  void initState() {
    super.initState();
    subject = widget.entry?.subject ?? '';
    day = widget.entry?.day ?? 'Monday';
    teacherId = widget.entry?.teacherId ?? '';
    teacherName = widget.entry?.teacherName ?? '';
    startTime = widget.entry?.startTime ?? '08:00';
    endTime = widget.entry?.endTime ?? '08:45';
    room = widget.entry?.room ?? '';
    if (widget.entry != null) {
      for (int i = 0; i < _periodSlots.length; i++) {
        if (_periodSlots[i]['start'] == startTime && _periodSlots[i]['end'] == endTime) {
          selectedPeriodIndex = i;
          break;
        }
      }
    }
  }
  Future<void> _pickTime(bool isStart) async {
    final parts = (isStart ? startTime : endTime).split(':');
    final initial = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isStart) {
          startTime = formatted;
        } else {
          endTime = formatted;
        }
        selectedPeriodIndex = null;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.entry == null ? '📅 Add Period' : '✏️ Edit Period',
        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: day,
                decoration: const InputDecoration(labelText: 'Day', prefixIcon: Icon(Icons.calendar_today_rounded)),
                items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
                    .map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (val) => setState(() => day = val!),
              ),
              const SizedBox(height: 12),
              Text('Select Period Slot', style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: List.generate(_periodSlots.length, (i) {
                  final slot = _periodSlots[i];
                  final isSelected = selectedPeriodIndex == i;
                  return GestureDetector(
                    onTap: () => setState(() {
                      selectedPeriodIndex = i;
                      startTime = slot['start']!;
                      endTime = slot['end']!;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF4F46E5) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF4F46E5) : Colors.grey[300]!,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            slot['label']!,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            '${slot['start']} - ${slot['end']}',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              color: isSelected ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickTime(true),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Start Time',
                          prefixIcon: const Icon(Icons.access_time_rounded),
                          border: const OutlineInputBorder(),
                          filled: selectedPeriodIndex == null,
                          fillColor: Colors.indigo[50],
                        ),
                        child: Text(startTime, style: GoogleFonts.outfit(fontSize: 14)),
                      ),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('→')),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickTime(false),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'End Time',
                          prefixIcon: const Icon(Icons.access_time_rounded),
                          border: const OutlineInputBorder(),
                          filled: selectedPeriodIndex == null,
                          fillColor: Colors.indigo[50],
                        ),
                        child: Text(endTime, style: GoogleFonts.outfit(fontSize: 14)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: subject,
                decoration: const InputDecoration(labelText: 'Subject', prefixIcon: Icon(Icons.book_rounded)),
                onChanged: (val) => subject = val,
                validator: (val) => val!.isEmpty ? 'Enter subject' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: room,
                decoration: const InputDecoration(labelText: 'Room', prefixIcon: Icon(Icons.room_rounded)),
                onChanged: (val) => room = val,
                validator: (val) => val!.isEmpty ? 'Enter room' : null,
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<TeacherModel>>(
                stream: FirestoreService().getTeachers(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red));
                  }
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final teachers = snapshot.data!;
                  if (teachers.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8)),
                      child: const Text('⚠️ Please add teachers first.', style: TextStyle(color: Colors.deepOrange)),
                    );
                  }
                  return DropdownButtonFormField<String>(
                    value: (teacherId.isNotEmpty && teachers.any((t) => t.id == teacherId)) ? teacherId : null,
                    decoration: const InputDecoration(
                      labelText: 'Select Teacher',
                      prefixIcon: Icon(Icons.person_rounded),
                    ),
                    hint: const Text('Select a teacher'),
                    items: teachers.map((t) => DropdownMenuItem(
                      value: t.id,
                      child: Text(t.name),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          teacherId = val;
                          teacherName = teachers.firstWhere((t) => t.id == val).name;
                        });
                      }
                    },
                    validator: (val) => val == null ? 'Please select a teacher' : null,
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(
                '⚠️ A teacher cannot be assigned two periods at the same time.',
                style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (widget.entry != null)
          TextButton(
            onPressed: _isSaving ? null : _delete,
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _save,
          icon: _isSaving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.save_rounded, size: 18),
          label: Text(_isSaving ? 'Saving...' : 'Save'),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
        ),
      ],
    );
  }
  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (startTime.compareTo(endTime) >= 0) {
      _showConflictDialog('Time Error', 'End time must be after the start time.');
      return;
    }
    setState(() => _isSaving = true);
    final newEntry = TimetableModel(
      id: widget.entry?.id ?? '',
      className: widget.className,
      section: widget.section,
      day: day,
      subject: subject,
      teacherId: teacherId,
      teacherName: teacherName,
      startTime: startTime,
      endTime: endTime,
      room: room,
    );
    final error = await context.read<TimetableProvider>().upsertTimetableEntry(newEntry);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (error != null) {
      _showConflictDialog('Conflict Found ❌', error);
    } else {
      Navigator.pop(context);
    }
  }
  void _showConflictDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.red))),
          ],
        ),
        content: Text(message, style: GoogleFonts.outfit(fontSize: 14)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  void _delete() async {
    if (widget.entry == null) return;
    setState(() => _isSaving = true);
    final error = await context.read<TimetableProvider>().deleteTimetableEntry(widget.entry!.id);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      Navigator.pop(context);
    }
  }
}
class TimetableRequestsScreen extends StatefulWidget {
  const TimetableRequestsScreen({super.key});
  @override
  State<TimetableRequestsScreen> createState() => _TimetableRequestsScreenState();
}
class _TimetableRequestsScreenState extends State<TimetableRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimetableProvider>().fetchRequests();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Requests')),
      body: Consumer<TimetableProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          if (provider.requests.isEmpty) return const Center(child: Text('No pending requests'));
          return ListView.builder(
            itemCount: provider.requests.length,
            itemBuilder: (context, index) {
              final req = provider.requests[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text('${req.teacherName} - ${req.requestedSchedule}'),
                  subtitle: Text('Reason: ${req.reason}\nStatus: ${req.status}'),
                  trailing: req.status == 'pending'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => provider.updateRequestStatus(req.id, 'approved'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => provider.updateRequestStatus(req.id, 'rejected'),
                            ),
                          ],
                        )
                      : Text(req.status.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor(req.status))),
                ),
              );
            },
          );
        },
      ),
    );
  }
  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.orange;
    }
  }
}