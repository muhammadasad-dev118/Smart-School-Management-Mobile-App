import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class StudentHomework {
  final String id;
  final String subject;
  final String title;
  final String description;
  final String dueDate;
  final String className;
  final String teacherName;
  final String teacherId;
  final DateTime createdAt;
  StudentHomework({
    required this.id,
    required this.subject,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.className,
    required this.teacherName,
    required this.teacherId,
    required this.createdAt,
  });
  factory StudentHomework.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    String dateStr = 'No Date';
    if (data['dueDate'] != null) {
      if (data['dueDate'] is Timestamp) {
        DateTime dt = (data['dueDate'] as Timestamp).toDate();
        dateStr = "${dt.day}/${dt.month}/${dt.year}";
      } else {
        dateStr = data['dueDate'].toString();
      }
    }
    return StudentHomework(
      id: doc.id,
      subject: data['subject'] ?? 'General',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: dateStr,
      className: data['className'] ?? '',
      teacherName: data['teacherName'] ?? 'Teacher',
      teacherId: data['teacherId'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
class StudentHomeworkProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<List<StudentHomework>> getHomeworks(String className) {
    return _firestore
        .collection('homework')
        .snapshots()
        .map((snapshot) {
          final normalizedClassName = _normalize(className);
          return snapshot.docs
              .map((doc) => StudentHomework.fromFirestore(doc))
              .where((h) => _normalize(h.className) == normalizedClassName)
              .toList();
        });
  }
  Stream<List<Map<String, dynamic>>> getStudentSubmissions(String studentId) {
    return _firestore
        .collection('homework_submissions')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList());
  }
  String _normalize(String name) {
    return name.toLowerCase()
        .replaceAll('class', '')
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .trim();
  }
}