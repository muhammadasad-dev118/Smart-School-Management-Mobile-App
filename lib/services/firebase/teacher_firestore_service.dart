import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_school_unified/core/constants/app_constants.dart';
import 'package:smart_school_unified/models/teacher_student_models.dart';
import 'package:smart_school_unified/services/notifications/email_service.dart';
class TeacherFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final EmailService _emailService = EmailService();
  Stream<List<TeacherModuleStudentModel>> getStudentsByClass(String fullClassName) {
    String className = fullClassName;
    String? section;
    if (fullClassName.contains('-')) {
      final parts = fullClassName.split('-');
      className = parts[0].trim();
      section = parts[1].trim();
    }
    Query query = _db.collection(AppConstants.studentsCollection)
        .where('className', isEqualTo: className);
    if (section != null) {
      query = query.where('section', isEqualTo: section);
    }
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => TeacherModuleStudentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }
  Future<void> markAttendance({
    required String className,
    required DateTime date,
    required String teacherId,
    required String teacherName,
    required String subject,
    required Map<String, bool> attendanceData,
  }) async {
    final dateString = "${date.year}-${date.month}-${date.day}";
    await _db
        .collection(AppConstants.attendanceCollection)
        .doc("$className-$teacherId-$subject-$dateString")
        .set({
      'className': className,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'subject': subject,
      'date': Timestamp.fromDate(date),
      'attendance': attendanceData,
    });
  }
  Future<Map<String, bool>?> getAttendance({
    required String className,
    required DateTime date,
    required String teacherId,
    required String subject,
  }) async {
    final dateString = "${date.year}-${date.month}-${date.day}";
    final doc = await _db
        .collection(AppConstants.attendanceCollection)
        .doc("$className-$teacherId-$subject-$dateString")
        .get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['attendance'] != null) {
        return Map<String, bool>.from(data['attendance']);
      }
    }
    return null;
  }
  Future<void> uploadHomework({
    required String className,
    required String title,
    required String description,
    required DateTime dueDate,
    required String teacherId,
    required String teacherName,
    required String subject,
  }) async {
    await _db.collection(AppConstants.homeworkCollection).add({
      'className': className,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'teacherId': teacherId,
      'teacherName': teacherName,
      'subject': subject,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  Stream<QuerySnapshot> getNoticesForTeachers() {
    return _db
        .collection(AppConstants.noticesCollection)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
  Future<void> sendNotice({
    required String title,
    required String content,
    required String category,
    required String teacherName,
    required String teacherId,
    String? className,
  }) async {
    List<String> sentTo = ['teacher', 'admin'];
    if (category == 'General') {
      sentTo.add('student');
    } else if (className != null) {
      sentTo.add(className);
    }
    await _db.collection(AppConstants.noticesCollection).add({
      'title': title,
      'message': content,
      'category': category,
      'className': className,
      'sentBy': teacherName,
      'sentTo': sentTo,
      'readBy': [],
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }
  Future<void> uploadMarks({
    required String className,
    required String subject,
    required String teacherId,
    required String teacherName,
    required String examTitle,
    required double totalMarks,
    required Map<String, Map<String, dynamic>> marksData,
  }) async {
    final batch = _db.batch();
    for (var entry in marksData.entries) {
      final studentId = entry.key;
      final data = entry.value;
      final docRef = _db.collection('marks').doc();
      batch.set(docRef, {
        'className': className,
        'subject': subject,
        'teacherId': teacherId,
        'teacherName': teacherName,
        'examTitle': examTitle,
        'totalMarks': totalMarks,
        'studentId': studentId,
        'studentEmail': data['email'],
        'marks': data['marks'],
        'createdAt': FieldValue.serverTimestamp(),
        'emailSent': true,
      });
      if (data['email'] != null &&
          data['email'].toString().isNotEmpty &&
          AppConstants.whitelistedEmails.contains(data['email'].toString())) {
        await _emailService.sendMarksNotification(
          studentEmail: data['email'],
          studentName: 'Student',
          subject: subject,
          marks: data['marks'].toString(),
          totalMarks: totalMarks.toString(),
        );
      }
    }
    await batch.commit();
  }
  Stream<List<QueryDocumentSnapshot>> getHomeworkSubmissions(String className, {String? teacherId}) {
    final targetNormalized = _normalize(className);
    return _db
        .collection('homework_submissions')
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs.where((doc) {
            final data = doc.data();
            final docClass = data['className'] ?? '';
            bool classMatches = _normalize(docClass) == targetNormalized;
            bool teacherMatches = true;
            if (teacherId != null && data.containsKey('teacherId') && data['teacherId'] != null) {
               teacherMatches = data['teacherId'] == teacherId;
            } else if (teacherId != null && data.containsKey('subject')) {
            }
            return classMatches && teacherMatches;
          }).toList();
          docs.sort((a, b) {
            final aTime = a.data()['submittedAt'] as Timestamp?;
            final bTime = b.data()['submittedAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });
          return docs;
        });
  }
  String _normalize(String name) {
    if (name.isEmpty) return "";
    return name.toLowerCase()
        .replaceAll('class', '')
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .trim();
  }
  Future<void> updateHomeworkFeedback({
    required String submissionId,
    required String studentId,
    required String feedback,
    required String homeworkTitle,
    required String subject,
    required String teacherName,
  }) async {
    await _db.collection('homework_submissions').doc(submissionId).update({
      'feedback': feedback,
      'status': 'Checked',
    });
    final studentDoc = await _db.collection('students').doc(studentId).get();
    final studentEmail = studentDoc.data()?['email'];
    await _db.collection('notifications').add({
      'studentId': studentId,
      'title': 'Homework Checked',
      'message': 'Your $subject homework "$homeworkTitle" has been checked by $teacherName. Feedback: $feedback',
      'type': 'homework',
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (studentEmail != null && studentEmail.isNotEmpty) {
      await _emailService.sendHomeworkNotification(
        studentEmail: studentEmail,
        studentName: 'Student',
        homeworkTitle: homeworkTitle,
        status: 'Checked',
        feedback: feedback,
      );
    }
  }
}