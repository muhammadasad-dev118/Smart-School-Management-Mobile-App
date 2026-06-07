import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_school_unified/core/constants/app_constants.dart';
import 'package:smart_school_unified/models/user_model.dart';
import 'package:smart_school_unified/models/student_model.dart';
import 'package:smart_school_unified/models/teacher_model.dart';
import 'package:smart_school_unified/models/fee_model.dart';
import 'package:smart_school_unified/models/notice_model.dart';
import 'package:smart_school_unified/services/notifications/email_service.dart';
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final EmailService _emailService = EmailService();
  Future<void> createUser(UserModel user) async {
    await _db.collection(AppConstants.usersCollection).doc(user.uid).set(user.toMap());
  }
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }
  Stream<List<StudentModel>> getStudents({String? className}) {
    Query query = _db.collection(AppConstants.studentsCollection)
        .orderBy('name');
    if (className != null && className != 'All Classes') {
      query = query.where('className', isEqualTo: className);
    }
    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => StudentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }
  Future<void> addStudent(StudentModel student, {String? docId}) async {
    if (docId != null) {
      await _db.collection(AppConstants.studentsCollection).doc(docId).set(student.toMap());
    } else {
      await _db.collection(AppConstants.studentsCollection).add(student.toMap());
    }
  }
  Future<void> updateStudent(String id, Map<String, dynamic> data) async {
    await _db.collection(AppConstants.studentsCollection).doc(id).update(data);
  }
  Future<void> deleteStudent(String id) async {
    await _db.collection(AppConstants.studentsCollection).doc(id).delete();
  }
  Future<int> getStudentCount() async {
    final snapshot = await _db.collection(AppConstants.studentsCollection).count().get();
    return snapshot.count ?? 0;
  }
  Stream<List<TeacherModel>> getTeachers() {
    return _db.collection(AppConstants.teachersCollection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => TeacherModel.fromMap(doc.data(), doc.id)).toList());
  }
  Future<void> addTeacher(TeacherModel teacher) async {
    await _db.collection(AppConstants.teachersCollection).doc(teacher.id).set(teacher.toMap());
  }
  Future<void> updateTeacher(String id, Map<String, dynamic> data) async {
    await _db.collection(AppConstants.teachersCollection).doc(id).update(data);
  }
  Future<void> deleteTeacher(String id) async {
    await _db.collection(AppConstants.teachersCollection).doc(id).delete();
  }
  Future<int> getTeacherCount() async {
    final snapshot = await _db.collection(AppConstants.teachersCollection).count().get();
    return snapshot.count ?? 0;
  }
  Stream<List<FeeModel>> getFees({String? status}) {
    return _db.collection(AppConstants.feesCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final all = snapshot.docs.map((doc) => FeeModel.fromMap(doc.data(), doc.id)).toList();
          if (status == null || status == 'All Records') return all;
          return all.where((f) => f.status.toLowerCase() == status.toLowerCase()).toList();
        });
  }
  Future<void> addFee(FeeModel fee) async {
    await _db.collection(AppConstants.feesCollection).add(fee.toMap());
    try {
      String studentId = fee.studentId;
      String studentEmail = '';
      final snapshot = await _db.collection(AppConstants.studentsCollection)
          .where('rollNumber', isEqualTo: fee.rollNumber)
          .get();
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        studentId = doc.id;
        studentEmail = doc.data()['email'] ?? '';
      }
      if (fee.status == 'paid' && studentEmail.isNotEmpty) {
        await _db.collection('payments').add({
          'studentEmail': studentEmail,
          'studentName': fee.studentName,
          'amount': fee.amount,
          'month': _getMonthName(fee.dueDate),
          'status': 'Paid',
          'timestamp': FieldValue.serverTimestamp(),
          'emailSent': false,
        });
        if (AppConstants.whitelistedEmails.contains(studentEmail)) {
          await _emailService.sendPaymentConfirmation(
            studentEmail: studentEmail,
            studentName: fee.studentName,
            amount: fee.amount,
            month: _getMonthName(fee.dueDate),
          );
        }
      }
      if (studentId.isNotEmpty) {
        await _db.collection('notifications').add({
          'studentId': studentId,
          'title': 'Fee Payment Received',
          'message': 'Your fee of Rs ${fee.amount} has been received successfully. Thank you!',
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
          'type': 'fee',
        });
      }
    } catch (e) {
      debugPrint('Error recording payment or notification: $e');
    }
  }
  String _getMonthName(DateTime date) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[date.month - 1];
  }
  Future<void> updateFeeStatus(String id, String status, {DateTime? paidDate}) async {
    final docRef = _db.collection(AppConstants.feesCollection).doc(id);
    final data = <String, dynamic>{'status': status};
    if (paidDate != null) {
      data['paidDate'] = Timestamp.fromDate(paidDate);
    }
    await docRef.update(data);
    if (status == 'paid') {
      try {
        final feeDoc = await docRef.get();
        final feeData = feeDoc.data() as Map<String, dynamic>;
        final studentRoll = feeData['rollNumber'] ?? '';
        final studentName = feeData['studentName'] ?? 'Student';
        final amount = feeData['amount'] ?? 0.0;
        final snapshot = await _db.collection(AppConstants.studentsCollection)
            .where('rollNumber', isEqualTo: studentRoll)
            .limit(1)
            .get();
        if (snapshot.docs.isNotEmpty) {
          final studentDoc = snapshot.docs.first;
          final studentEmail = studentDoc.data()['email'] ?? '';
          if (studentEmail.isNotEmpty && AppConstants.whitelistedEmails.contains(studentEmail)) {
            await _emailService.sendPaymentConfirmation(
              studentEmail: studentEmail,
              studentName: studentName,
              amount: amount.toDouble(),
              month: _getMonthName(paidDate ?? DateTime.now()),
            );
          }
          await _db.collection('notifications').add({
            'studentId': studentDoc.id,
            'title': 'Fee Paid Successfully',
            'message': 'Your fee of Rs $amount has been marked as paid. Thank you!',
            'createdAt': FieldValue.serverTimestamp(),
            'isRead': false,
            'type': 'fee',
          });
        }
      } catch (e) {
        debugPrint('Error sending fee payment notification: $e');
      }
    }
  }
  Future<double> getTotalFees() async {
    final snapshot = await _db.collection(AppConstants.feesCollection).get();
    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc.data()['amount'] ?? 0.0).toDouble();
    }
    return total;
  }
  Future<double> getCollectedFees() async {
    final snapshot = await _db.collection(AppConstants.feesCollection)
        .where('status', isEqualTo: 'paid')
        .get();
    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc.data()['amount'] ?? 0.0).toDouble();
    }
    return total;
  }
  Stream<List<NoticeModel>> getNotices({String? category}) {
    return _db
        .collection(AppConstants.noticesCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      final all = snapshot.docs
          .map((doc) => NoticeModel.fromMap(doc.data(), doc.id))
          .toList();
      if (category == null || category == 'All') return all;
      return all.where((n) => n.category.toLowerCase() == category.toLowerCase()).toList();
    });
  }
  Future<void> addNotice(NoticeModel notice) async {
    await _db.collection(AppConstants.noticesCollection).add(notice.toMap());
    try {
      final String noticeTitle = 'School Notice: ${notice.title}';
      final String noticeMessage = notice.message;
      if (notice.sentTo.contains('teacher')) {
        final teachersSnapshot = await _db.collection(AppConstants.teachersCollection).get();
        for (var doc in teachersSnapshot.docs) {
          final teacherEmail = doc.data()['email'] ?? '';
          if (teacherEmail.isNotEmpty && AppConstants.whitelistedEmails.contains(teacherEmail)) {
             await _emailService.sendTeacherNotification(
              teacherEmail: teacherEmail,
              message: noticeMessage,
            );
          }
        }
      }
      if (notice.sentTo.contains('student')) {
        final studentsSnapshot = await _db.collection(AppConstants.studentsCollection).get();
        for (var doc in studentsSnapshot.docs) {
          final studentEmail = doc.data()['email'] ?? '';
          if (studentEmail.isNotEmpty && AppConstants.whitelistedEmails.contains(studentEmail)) {
            await _emailService.sendStudentNotification(
              studentEmail: studentEmail,
              title: noticeTitle,
              message: noticeMessage,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error sending notice emails: $e');
    }
  }
  Future<void> deleteNotice(String id) async {
    await _db.collection(AppConstants.noticesCollection).doc(id).delete();
  }
  Future<double> getAverageAttendance() async {
    try {
      final snapshot = await _db.collection(AppConstants.attendanceCollection).get();
      if (snapshot.docs.isEmpty) return 0.0;
      int totalStudents = 0;
      int presentStudents = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['attendance'] != null && data['attendance'] is Map) {
          final Map attendanceMap = data['attendance'];
          totalStudents += attendanceMap.length;
          presentStudents += attendanceMap.values.where((v) => v == true).length;
        }
      }
      if (totalStudents == 0) return 0.0;
      return (presentStudents / totalStudents) * 100;
    } catch (e) {
      return 0.0;
    }
  }
  Stream<Map<String, dynamic>> schoolConfigStream() {
    return _db.collection('config').doc('school_settings').snapshots().map((doc) {
      if (doc.exists) return doc.data() as Map<String, dynamic>;
      return {
        'schoolName': AppConstants.appName,
        'tagline': AppConstants.tagline,
        'address': 'Your School Address',
        'phone': '123-456-7890',
        'academicYear': '2023-2024',
        'semester': 'Spring',
      };
    });
  }
  Future<Map<String, dynamic>> getSchoolConfig() async {
    try {
      final doc = await _db.collection('config').doc('school_settings').get();
      if (doc.exists) return doc.data() as Map<String, dynamic>;
      return {
        'schoolName': AppConstants.appName,
        'tagline': AppConstants.tagline,
        'address': 'Your School Address',
        'phone': '123-456-7890',
      };
    } catch (e) {
      return {};
    }
  }
  Future<void> updateSchoolConfig(Map<String, dynamic> settings) async {
    await _db.collection('config').doc('school_settings').set(settings, SetOptions(merge: true));
  }
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final studentCount = await getStudentCount();
      final teacherCount = await getTeacherCount();
      final totalFees = await getTotalFees();
      final collectedFees = await getCollectedFees();
      final avgAttendance = await getAverageAttendance();
      final usersSnapshot = await _db.collection(AppConstants.usersCollection).count().get();
      final userCount = usersSnapshot.count ?? 0;
      final classesCount = AppConstants.classes.length;
      return {
        'students': studentCount,
        'teachers': teacherCount,
        'totalFees': totalFees,
        'collectedFees': collectedFees,
        'avgAttendance': avgAttendance.toStringAsFixed(1),
        'classes': classesCount,
        'activeUsers': userCount,
        'pendingTasks': 0,
      };
    } catch (e) {
      debugPrint('Error getting dashboard stats: $e');
      return {
        'students': 0,
        'teachers': 0,
        'totalFees': 0,
        'collectedFees': 0,
        'avgAttendance': '0.0',
        'classes': 0,
        'activeUsers': 0,
        'pendingTasks': 0,
      };
    }
  }
}