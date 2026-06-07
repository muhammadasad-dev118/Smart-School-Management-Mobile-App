import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_school_unified/modules/student/features/student/models/student_model.dart';
class StudentFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Future<StudentModuleStudentModel?> getStudentData(String studentId) async {
    try {
      final doc = await _db.collection('students').doc(studentId).get();
      if (doc.exists) {
        return StudentModuleStudentModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      debugPrint('Error fetching student data: $e');
    }
    return null;
  }
  Stream<QuerySnapshot> getNotices() {
    return _db.collection('notices')
        .where('status', isEqualTo: 'approved')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
  Stream<QuerySnapshot> getHomework(String className) {
    return _db
        .collection('homework')
        .where('className', isEqualTo: className)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
  Future<void> submitHomework({
    required String homeworkId,
    required String studentId,
    required String studentName,
    required String className,
    required String fileName,
    required Uint8List fileBytes,
    required String homeworkTitle,
    required String subject,
    required String studentRollNumber,
    required String teacherId,
  }) async {
    if (fileBytes.isEmpty) {
      throw 'Selected file is empty or corrupted. Please try again.';
    }
    debugPrint('Step 1: Converting file to Base64 (FYP Mode)');
    final String base64File = base64Encode(fileBytes);
    if (base64File.length > 1000000) {
      throw 'File is too large for the free plan (Max 1MB). Please use a smaller file.';
    }
    debugPrint('Step 2: Saving to Firestore...');
    await _db.collection('homework_submissions').add({
      'homeworkId': homeworkId,
      'homeworkTitle': homeworkTitle,
      'subject': subject,
      'studentId': studentId,
      'studentName': studentName,
      'studentRollNumber': studentRollNumber,
      'className': className,
      'content': fileName,
      'fileData': base64File,
      'status': 'Pending',
      'feedback': '',
      'submittedAt': FieldValue.serverTimestamp(),
    });
    await _db.collection('teacher_notifications').add({
      'teacherId': teacherId,
      'title': 'New Homework Submission',
      'message': '$studentName (Roll No: $studentRollNumber) submitted homework for $subject: "$homeworkTitle"',
      'type': 'homework',
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
    debugPrint('Step 3: Save complete.');
  }
  Stream<QuerySnapshot> getStudentNotifications(String studentId) {
    return _db
        .collection('notifications')
        .where('studentId', isEqualTo: studentId)
        .snapshots();
  }
  Stream<QuerySnapshot> getAttendanceForClass(String className) {
    return _db
        .collection('attendance')
        .snapshots()
        .map((snapshot) {
          return snapshot;
        });
  }
  Stream<QuerySnapshot> getMarksForClass(String className) {
    return _db
        .collection('marks')
        .where('className', isEqualTo: className)
        .snapshots();
  }
  String normalize(String name) {
    return name.toLowerCase()
        .replaceAll('class', '')
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .trim();
  }
}