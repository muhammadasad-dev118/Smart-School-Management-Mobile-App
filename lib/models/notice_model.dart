import 'package:cloud_firestore/cloud_firestore.dart';
class NoticeModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final List<String> sentTo;
  final List<String> readBy;
  final String category;
  final String sentBy;
  final String? className;
  final String status;
  NoticeModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.sentTo,
    required this.readBy,
    this.category = 'General',
    this.sentBy = 'Admin',
    this.className,
    this.status = 'approved',
  });
  factory NoticeModel.fromMap(Map<String, dynamic> map, String id) {
    return NoticeModel(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sentTo: List<String>.from(map['sentTo'] ?? []),
      readBy: List<String>.from(map['readBy'] ?? []),
      category: map['category'] ?? 'General',
      sentBy: map['sentBy'] ?? 'Admin',
      className: map['className'],
      status: map['status'] ?? 'approved',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'sentTo': sentTo,
      'readBy': readBy,
      'category': category,
      'sentBy': sentBy,
      'className': className,
      'status': status,
    };
  }
  bool isRead(String userId) => readBy.contains(userId);
  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}