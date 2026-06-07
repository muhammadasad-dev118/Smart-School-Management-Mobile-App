import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../models/notice_model.dart';
import 'email_service.dart';
class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final EmailService _emailService = EmailService();
  Future<void> sendNotice({
    required String title,
    required String message,
    required List<String> sentTo,
    String category = 'General',
    String sentBy = 'Admin',
  }) async {
    try {
      await _db.collection(AppConstants.noticesCollection).add({
        'title': title,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'sentTo': sentTo,
        'readBy': [],
        'category': category,
        'sentBy': sentBy,
        'status': 'approved',
      });
      final List<String> whitelist = AppConstants.whitelistedEmails;
      if (sentTo.contains('teacher')) {
        final teachers = await _db.collection(AppConstants.teachersCollection).get();
        for (var doc in teachers.docs) {
          final email = doc.data()['email'];
          if (email != null && email.isNotEmpty && whitelist.contains(email)) {
            await _emailService.sendTeacherNotification(
              teacherEmail: email,
              message: message
            );
          }
        }
      }
      if (sentTo.contains('student')) {
        final students = await _db.collection(AppConstants.studentsCollection).get();
        for (var doc in students.docs) {
          final email = doc.data()['email'];
          if (email != null && email.isNotEmpty && whitelist.contains(email)) {
            await _emailService.sendStudentNotification(
              studentEmail: email,
              title: title,
              message: message
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error sending notice: $e');
    }
  }
  Stream<List<NoticeModel>> getNotices(List<String> targets) {
    Query query = _db.collection('notices');
    if (!targets.contains('admin')) {
      query = query.where('status', isEqualTo: 'approved');
    }
    if (targets.isEmpty) return Stream.value([]);
    return query
        .where('sentTo', arrayContainsAny: targets)
        .snapshots()
        .map((snapshot) {
      final notices = snapshot.docs
          .map((doc) => NoticeModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      notices.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return notices;
    });
  }
  Future<void> updateNoticeStatus(String noticeId, String status) async {
    await _db.collection('notices').doc(noticeId).update({
      'status': status,
    });
  }
  Future<void> markAsRead(String noticeId, String userId) async {
    try {
      await _db.collection('notices').doc(noticeId).update({
        'readBy': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      debugPrint('Error marking notice as read: $e');
    }
  }
  Future<void> markAllAsRead(List<String> noticeIds, String userId) async {
    final batch = _db.batch();
    for (var id in noticeIds) {
      final docRef = _db.collection('notices').doc(id);
      batch.update(docRef, {
        'readBy': FieldValue.arrayUnion([userId])
      });
    }
    await batch.commit();
  }
}