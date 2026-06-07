import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_school_unified/core/theme/app_theme.dart';
import 'package:smart_school_unified/core/constants/app_constants.dart';
import 'package:smart_school_unified/models/teacher_model.dart';
import 'package:smart_school_unified/services/firebase/firestore_service.dart';
import 'package:smart_school_unified/services/auth/auth_service.dart';
class TeacherManagementScreen extends StatelessWidget {
  const TeacherManagementScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firestoreService = FirestoreService();
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Teachers'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FACULTY MANAGEMENT', style: theme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.teal, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                StreamBuilder<List<TeacherModel>>(
                  stream: firestoreService.getTeachers(),
                  builder: (context, snap) {
                    final count = snap.data?.length ?? 0;
                    return Text('$count Teachers', style: theme.textTheme.displayMedium);
                  },
                ),
                const SizedBox(height: 4),
                Text('Overseeing academic excellence and classroom engagement.',
                  style: theme.textTheme.bodySmall),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/add-teacher'),
                    icon: const Icon(Icons.person_add_alt_1, size: 18),
                    label: const Text('Add New Faculty'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<TeacherModel>>(
              stream: firestoreService.getTeachers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryIndigo));
                }
                final teachers = snapshot.data ?? [];
                if (teachers.isEmpty) {
                  return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.school_outlined, size: 64, color: AppTheme.onSurfaceVariant.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    Text('No teachers yet', style: theme.textTheme.titleMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                  ]));
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: teachers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, i) => _TeacherCard(teacher: teachers[i]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => Navigator.pushNamed(context, '/add-teacher'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
class _TeacherCard extends StatelessWidget {
  final TeacherModel teacher;
  const _TeacherCard({required this.teacher});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.ambientShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 24, backgroundColor: AppTheme.surfaceContainerLow,
            child: Text(teacher.name.isNotEmpty ? teacher.name[0] : '?',
              style: const TextStyle(color: AppTheme.primaryIndigo, fontWeight: FontWeight.w700, fontSize: 18))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(teacher.name, style: theme.textTheme.titleMedium),
            Text('ID: ${teacher.id}', style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: Colors.grey[400])),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(teacher.subject, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.teal, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(teacher.assignedClasses.join(', '), style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ])),
              IconButton(
                icon: Icon(Icons.edit_outlined, size: 20.sp, color: Colors.grey),
                onPressed: () => Navigator.pushNamed(context, '/add-teacher', arguments: teacher),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, size: 20.sp, color: Colors.red[300]),
                onPressed: () => _showDeleteDialog(context, teacher),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(children: [
            _miniStat('STUDENTS', '${teacher.studentCount}'),
            const SizedBox(width: 16),
            _miniStat('ATTENDANCE', '${teacher.attendanceRate.toStringAsFixed(0)}%'),
            const SizedBox(width: 16),
            _miniStat('RATING', '${teacher.rating.toStringAsFixed(1)}★'),
          ]),
        ],
      ),
    );
  }
  void _showDeleteDialog(BuildContext context, TeacherModel teacher) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Teacher'),
        content: Text('Are you sure you want to remove ${teacher.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              FirestoreService().deleteTeacher(teacher.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  Widget _miniStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: AppTheme.surfaceContainerLow, borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.onSurfaceVariant, letterSpacing: 0.8)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryIndigo)),
      ]),
    );
  }
}
class AddTeacherScreen extends StatefulWidget {
  const AddTeacherScreen({super.key});
  @override
  State<AddTeacherScreen> createState() => _AddTeacherScreenState();
}
class _AddTeacherScreenState extends State<AddTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final _idCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  List<String> _selectedClasses = [];
  TeacherModel? _editTeacher;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is TeacherModel) {
        setState(() {
          _editTeacher = args;
          _idCtrl.text = args.id;
          _nameCtrl.text = args.name;
          _subjectCtrl.text = args.subject;
          _emailCtrl.text = args.email;
          _passwordCtrl.text = args.password;
          _phoneCtrl.text = args.phone;
          _selectedClasses = List<String>.from(args.assignedClasses);
        });
      }
    });
  }
  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedClasses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select at least one class'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final teacherData = TeacherModel(
        id: _idCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        subject: _subjectCtrl.text.trim(),
        assignedClasses: _selectedClasses,
        email: _emailCtrl.text.trim().toLowerCase(),
        password: _passwordCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        joinedAt: _editTeacher?.joinedAt ?? DateTime.now(),
        studentCount: _editTeacher?.studentCount ?? 0,
        attendanceRate: _editTeacher?.attendanceRate ?? 0.0,
        rating: _editTeacher?.rating ?? 0.0,
      );
      if (_editTeacher != null) {
        await _firestoreService.updateTeacher(_editTeacher!.id, teacherData.toMap());
      } else {
        final authService = AuthService();
        final userCredential = await authService.createAccount(teacherData.email, teacherData.password);
        final uid = userCredential.user!.uid;
        final finalTeacher = TeacherModel(
          id: uid,
          employeeId: teacherData.id,
          name: teacherData.name,
          subject: teacherData.subject,
          assignedClasses: teacherData.assignedClasses,
          email: teacherData.email,
          password: teacherData.password,
          phone: teacherData.phone,
          joinedAt: teacherData.joinedAt,
        );
        await _firestoreService.addTeacher(finalTeacher);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Teacher saved successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save teacher: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _isLoading = false);
  }
  @override
  void dispose() { _idCtrl.dispose(); _nameCtrl.dispose(); _subjectCtrl.dispose(); _emailCtrl.dispose(); _passwordCtrl.dispose(); _phoneCtrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        title: Text(_editTeacher != null ? 'Edit Teacher' : 'Add Teacher'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label('Teacher ID (Unique ID)'),
            TextFormField(
              controller: _idCtrl,
              enabled: true,
              decoration: const InputDecoration(hintText: 'e.g. T001, SIR_ANWAR, etc.'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _label('Full Name'),
            TextFormField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Full Name'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null),
            const SizedBox(height: 16),
            _label('Subject'),
            TextFormField(controller: _subjectCtrl, decoration: const InputDecoration(hintText: 'e.g. Mathematics')),
            const SizedBox(height: 16),
            _label('Assign Classes'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.classes.expand((c) => AppConstants.sections.map((s) => '$c-$s')).map((cs) {
                final isSelected = _selectedClasses.contains(cs);
                return FilterChip(
                  label: Text(cs, style: TextStyle(fontSize: 12.sp, color: isSelected ? Colors.white : Colors.black87)),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryIndigo,
                  checkmarkColor: Colors.white,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedClasses.add(cs);
                      } else {
                        _selectedClasses.remove(cs);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _label('Email'),
            TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'email@school.com')),
            const SizedBox(height: 16),
            _label('Login Password'),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              validator: (v) => v == null || v.isEmpty ? 'Required' : v.length < 6 ? 'Password must be at least 6 characters' : null,
              decoration: InputDecoration(
                hintText: '••••••••',
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            _label('Phone'),
            TextFormField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: '+91 00000 00000')),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
              onPressed: _isLoading ? null : _save, child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(_editTeacher != null ? 'Update Teacher' : 'Add Teacher'))),
          ]),
        ),
      ),
    );
  }
  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 6),
    child: Text(t, style: Theme.of(context).textTheme.labelLarge));
}