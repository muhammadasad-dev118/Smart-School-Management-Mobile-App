import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_school_unified/models/timetable_model.dart';
import 'package:smart_school_unified/core/constants/app_constants.dart';
class TimetableProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<TimetableModel> _timetables = [];
  List<TimetableRequestModel> _requests = [];
  bool _isLoading = false;
  List<TimetableModel> get timetables => _timetables;
  List<TimetableRequestModel> get requests => _requests;
  bool get isLoading => _isLoading;
  Future<void> fetchTimetable(String className, String section) async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection(AppConstants.timetablesCollection)
          .where('className', isEqualTo: className)
          .where('section', isEqualTo: section)
          .get();
      _timetables = snapshot.docs
          .map((doc) => TimetableModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching timetable: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> fetchTeacherTimetable(String teacherId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection(AppConstants.timetablesCollection)
          .where('teacherId', isEqualTo: teacherId)
          .get();
      _timetables = snapshot.docs
          .map((doc) => TimetableModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching teacher timetable: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<String?> upsertTimetableEntry(TimetableModel entry) async {
    _isLoading = true;
    notifyListeners();
    try {
      final teacherConflict = await _firestore
          .collection(AppConstants.timetablesCollection)
          .where('teacherId', isEqualTo: entry.teacherId)
          .where('day', isEqualTo: entry.day)
          .get();
      for (var doc in teacherConflict.docs) {
        if (doc.id == entry.id) continue;
        final existing = TimetableModel.fromMap(doc.data(), doc.id);
        if (_isTimeOverlapping(entry.startTime, entry.endTime, existing.startTime, existing.endTime)) {
          return 'Teacher is already assigned to ${existing.className} ${existing.section} at this time.';
        }
      }
      final roomConflict = await _firestore
          .collection(AppConstants.timetablesCollection)
          .where('room', isEqualTo: entry.room)
          .where('day', isEqualTo: entry.day)
          .get();
      for (var doc in roomConflict.docs) {
        if (doc.id == entry.id) continue;
        final existing = TimetableModel.fromMap(doc.data(), doc.id);
        if (_isTimeOverlapping(entry.startTime, entry.endTime, existing.startTime, existing.endTime)) {
          return 'Room ${entry.room} is already occupied at this time.';
        }
      }
      final classConflict = await _firestore
          .collection(AppConstants.timetablesCollection)
          .where('className', isEqualTo: entry.className)
          .where('section', isEqualTo: entry.section)
          .where('day', isEqualTo: entry.day)
          .get();
      for (var doc in classConflict.docs) {
        if (doc.id == entry.id) continue;
        final existing = TimetableModel.fromMap(doc.data(), doc.id);
        if (_isTimeOverlapping(entry.startTime, entry.endTime, existing.startTime, existing.endTime)) {
          return 'This class already has a subject scheduled at this time.';
        }
      }
      if (entry.id.isEmpty) {
        await _firestore.collection(AppConstants.timetablesCollection).add(entry.toMap());
      } else {
        await _firestore.collection(AppConstants.timetablesCollection).doc(entry.id).update(entry.toMap());
      }
      return null;
    } catch (e) {
      return 'Error saving timetable: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  bool _isTimeOverlapping(String start1, String end1, String start2, String end2) {
    return start1.compareTo(end2) < 0 && end1.compareTo(start2) > 0;
  }
  Future<void> submitRequest(TimetableRequestModel request) async {
    try {
      await _firestore.collection(AppConstants.timetableRequestsCollection).add(request.toMap());
    } catch (e) {
      debugPrint('Error submitting request: $e');
    }
  }
  Future<void> fetchRequests() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection(AppConstants.timetableRequestsCollection)
          .orderBy('createdAt', descending: true)
          .get();
      _requests = snapshot.docs
          .map((doc) => TimetableRequestModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching requests: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      await _firestore.collection(AppConstants.timetableRequestsCollection).doc(requestId).update({
        'status': status,
      });
      final index = _requests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        fetchRequests();
      }
    } catch (e) {
      debugPrint('Error updating request status: $e');
    }
  }
  Future<String?> deleteTimetableEntry(String entryId) async {
    try {
      await _firestore.collection(AppConstants.timetablesCollection).doc(entryId).delete();
      _timetables.removeWhere((e) => e.id == entryId);
      notifyListeners();
      return null;
    } catch (e) {
      return 'Error deleting entry: $e';
    }
  }
}