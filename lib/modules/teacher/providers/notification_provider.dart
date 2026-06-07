import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_school_unified/models/notification_model.dart';
class TeacherNotificationProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<TeacherNotificationModel> _notifications = [];
  List<TeacherNotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  void listenToNotifications(String teacherId) {
    _db
        .collection('teacher_notifications')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .listen((snapshot) {
      _notifications = snapshot.docs
          .map((doc) => TeacherNotificationModel.fromFirestore(doc))
          .toList();
      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    });
  }
  Future<void> markAsRead(String notificationId) async {
    await _db.collection('teacher_notifications').doc(notificationId).update({'isRead': true});
  }
  Future<void> deleteNotification(String notificationId) async {
    await _db.collection('teacher_notifications').doc(notificationId).delete();
  }
}