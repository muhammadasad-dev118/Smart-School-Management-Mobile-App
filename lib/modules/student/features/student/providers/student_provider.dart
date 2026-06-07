import 'package:flutter/material.dart';
import 'package:smart_school_unified/modules/student/features/student/models/student_model.dart';
import 'package:smart_school_unified/services/firebase/student_firestore_service.dart';
class StudentProvider with ChangeNotifier {
  final StudentFirestoreService _studentFirestoreService = StudentFirestoreService();
  StudentModuleStudentModel? _currentStudent;
  bool _isLoading = false;
  StudentModuleStudentModel? get currentStudent => _currentStudent;
  bool get isLoading => _isLoading;
  Future<void> fetchStudentData(String studentId) async {
    _isLoading = true;
    notifyListeners();
    _currentStudent = await _studentFirestoreService.getStudentData(studentId);
    _isLoading = false;
    notifyListeners();
  }
  void clear() {
    _currentStudent = null;
    notifyListeners();
  }
}