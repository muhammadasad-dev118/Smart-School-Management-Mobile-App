import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_school_unified/models/notification_model.dart';
import 'package:smart_school_unified/services/notifications/email_service.dart';
class NotificationProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final EmailService _emailService = EmailService();
  List<AdminNotificationModel> _notifications = [];
  List<AdminNotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => n.status == 'Unread').length;
  NotificationProvider() {
    _listenToNotifications();
  }
  void _listenToNotifications() {
    _db.collection('admin_notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _notifications = snapshot.docs
          .map((doc) => AdminNotificationModel.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    });
  }
  Future<void> markAsRead(String id) async {
    try {
      await _db.collection('admin_notifications').doc(id).update({'status': 'Read'});
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }
  Future<void> deleteNotification(String id) async {
    try {
      await _db.collection('admin_notifications').doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }
  Future<void> replyToRequest(String requestId, String studentEmail, String replyMessage) async {
    try {
      await _db.collection('admin_notifications').doc(requestId).update({
        'status': 'Replied',
        'adminReply': replyMessage,
        'repliedAt': FieldValue.serverTimestamp(),
      });
      final studentSnapshot = await _db
          .collection('students')
          .where('email', isEqualTo: studentEmail)
          .limit(1)
          .get();
      if (studentSnapshot.docs.isNotEmpty) {
        final studentId = studentSnapshot.docs.first.id;
        await _db.collection('notifications').add({
          'studentId': studentId,
          'title': 'Admin Response',
          'message': replyMessage,
          'type': 'support',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error replying to request: $e');
      rethrow;
    }
  }
  Future<void> sendAppNotification({
    required String receiverId,
    required String title,
    required String message,
    required String role,
  }) async {
    try {
      final collection = role == 'teacher' ? 'teacher_notifications' : 'notifications';
      final idField = role == 'teacher' ? 'teacherId' : 'studentId';
      await _db.collection(collection).add({
        idField: receiverId,
        'title': title,
        'message': message,
        'type': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (e) {
      debugPrint('Error sending app notification: $e');
      rethrow;
    }
  }
  Future<void> sendTeacherNotification(String teacherEmail, String message, {String? teacherId}) async {
    try {
      await _db.collection('notifications').add({
        'type': 'teacher',
        'receiverEmail': teacherEmail,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Sent',
        'emailSent': false,
      });
      if (teacherId != null) {
        await sendAppNotification(
          receiverId: teacherId,
          title: 'Admin Message',
          message: message,
          role: 'teacher',
        );
      }
      await _emailService.sendTeacherNotification(
        teacherEmail: teacherEmail,
        message: message,
      );
    } catch (e) {
      debugPrint('Error sending teacher notification: $e');
      rethrow;
    }
  }
}