import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_school_unified/models/timetable_model.dart';
class TimetableProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<TimetableModel> _timetables = [];
  bool _isLoading = false;
  List<TimetableModel> get timetables => _timetables;
  bool get isLoading => _isLoading;
  Future<void> fetchTimetable(String className, String section) async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('timetables')
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
}