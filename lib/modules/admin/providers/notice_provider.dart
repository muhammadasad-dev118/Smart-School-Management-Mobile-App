import 'package:flutter/material.dart';
import 'package:smart_school_unified/models/notice_model.dart';
import 'package:smart_school_unified/services/firebase/firestore_service.dart';
class NoticeProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Future<void> addNotice(NoticeModel notice) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.addNotice(notice);
    } catch (e) {
      debugPrint('Error adding notice: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Stream<List<NoticeModel>> getNotices(String? category) {
    return _firestoreService.getNotices(category: category);
  }
  Future<void> deleteNotice(String id) async {
    await _firestoreService.deleteNotice(id);
  }
}