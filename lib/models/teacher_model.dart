import 'package:cloud_firestore/cloud_firestore.dart';
class TeacherModel {
  final String id;
  final String? employeeId;
  final String name;
  final String subject;
  final List<String> assignedClasses;
  final String? photoUrl;
  final int studentCount;
  final double attendanceRate;
  final double rating;
  final String email;
  final String password;
  final String phone;
  final DateTime joinedAt;
  TeacherModel({
    required this.id,
    this.employeeId,
    required this.name,
    required this.subject,
    required this.assignedClasses,
    this.photoUrl,
    this.studentCount = 0,
    this.attendanceRate = 0.0,
    this.rating = 0.0,
    required this.email,
    required this.password,
    required this.phone,
    required this.joinedAt,
  });
  factory TeacherModel.fromMap(Map<String, dynamic> map, String id) {
    return TeacherModel(
      id: id,
      employeeId: map['employeeId']?.toString(),
      name: map['name']?.toString() ?? '',
      subject: map['subject']?.toString() ?? '',
      assignedClasses: (map['assignedClasses'] as List?)?.map((e) => e.toString()).toList() ??
                       (map['assignedClass'] != null ? [map['assignedClass'].toString()] : []),
      photoUrl: map['photoUrl']?.toString(),
      studentCount: map['studentCount'] ?? 0,
      attendanceRate: (map['attendanceRate'] ?? 0.0).toDouble(),
      rating: (map['rating'] ?? 0.0).toDouble(),
      email: map['email']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      joinedAt: (map['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'name': name,
      'subject': subject,
      'assignedClasses': assignedClasses,
      'photoUrl': photoUrl,
      'studentCount': studentCount,
      'attendanceRate': attendanceRate,
      'rating': rating,
      'email': email,
      'password': password,
      'phone': phone,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }
}