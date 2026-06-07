import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_school_unified/models/timetable_model.dart';
import 'package:smart_school_unified/core/constants/app_constants.dart';
class TimetableProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<TimetableModel> _teacherTimetable = [];
  List<TimetableRequestModel> _myRequests = [];
  bool _isLoading = false;
  List<TimetableModel> get teacherTimetable => _teacherTimetable;
  List<TimetableRequestModel> get myRequests => _myRequests;
  bool get isLoading => _isLoading;
  Future<void> fetchTeacherTimetable(String teacherId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection(AppConstants.timetablesCollection)
          .where('teacherId', isEqualTo: teacherId)
          .get();
      _teacherTimetable = snapshot.docs
          .map((doc) => TimetableModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching teacher timetable: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> submitRequest(TimetableRequestModel request) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestore.collection(AppConstants.timetableRequestsCollection).add(request.toMap());
      await fetchMyRequests(request.teacherId);
    } catch (e) {
      debugPrint('Error submitting request: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> fetchMyRequests(String teacherId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection(AppConstants.timetableRequestsCollection)
          .where('teacherId', isEqualTo: teacherId)
          .orderBy('createdAt', descending: true)
          .get();
      _myRequests = snapshot.docs
          .map((doc) => TimetableRequestModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching my requests: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}