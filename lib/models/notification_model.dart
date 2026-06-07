import 'package:cloud_firestore/cloud_firestore.dart';
class AdminNotificationModel {
  final String id;
  final String type;
  final String email;
  final String message;
  final String status;
  final DateTime createdAt;
  AdminNotificationModel({
    required this.id,
    required this.type,
    required this.email,
    required this.message,
    required this.status,
    required this.createdAt,
  });
  factory AdminNotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return AdminNotificationModel(
      id: id,
      type: map['type'] ?? 'General',
      email: map['email'] ?? '',
      message: map['message'] ?? '',
      status: map['status'] ?? 'Unread',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'email': email,
      'message': message,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
class TeacherNotificationModel {
  final String id;
  final String teacherId;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  final bool isRead;
  TeacherNotificationModel({
    required this.id,
    required this.teacherId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });
  factory TeacherNotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TeacherNotificationModel(
      id: doc.id,
      teacherId: data['teacherId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }
}