import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/notice_model.dart';
import 'notification_service.dart';
class AppNotificationProvider with ChangeNotifier {
  final NotificationService _service = NotificationService();
  List<NoticeModel> _notices = [];
  bool _isLoading = false;
  List<NoticeModel> get notices => _notices;
  bool get isLoading => _isLoading;
  int unreadCount(String userId) {
    return _notices.where((notice) => !notice.readBy.contains(userId)).length;
  }
  StreamSubscription? _noticeSubscription;
  void listenToNotices(dynamic target) {
    _noticeSubscription?.cancel();
    _isLoading = true;
    notifyListeners();
    List<String> targets = target is List<String> ? target : [target.toString()];
    _noticeSubscription = _service.getNotices(targets).listen((noticeList) {
      _notices = noticeList;
      _isLoading = false;
      notifyListeners();
    });
  }
  void clear() {
    _noticeSubscription?.cancel();
    _noticeSubscription = null;
    _notices = [];
    _isLoading = false;
    notifyListeners();
  }
  @override
  void dispose() {
    _noticeSubscription?.cancel();
    super.dispose();
  }
  Future<void> markAsRead(String noticeId, String userId) async {
    await _service.markAsRead(noticeId, userId);
  }
  Future<void> markAllAsRead(String userId) async {
    final unreadIds = _notices
        .where((n) => !n.readBy.contains(userId))
        .map((n) => n.id)
        .toList();
    if (unreadIds.isNotEmpty) {
      await _service.markAllAsRead(unreadIds, userId);
    }
  }
  Future<void> sendNotice({
    required String title,
    required String message,
    required List<String> sentTo,
    String category = 'General',
    String sentBy = 'Admin',
  }) async {
    await _service.sendNotice(
      title: title,
      message: message,
      sentTo: sentTo,
      category: category,
      sentBy: sentBy,
    );
  }
  Future<void> updateNoticeStatus(String noticeId, String status) async {
    await _service.updateNoticeStatus(noticeId, status);
  }
}