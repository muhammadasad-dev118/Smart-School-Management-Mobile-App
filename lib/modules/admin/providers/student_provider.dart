import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_school_unified/models/student_model.dart';
import 'package:smart_school_unified/services/firebase/firestore_service.dart';
class StudentProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<StudentModel> _students = [];
  bool _isLoading = false;
  StreamSubscription? _studentSubscription;
  List<StudentModel> get students => _students;
  bool get isLoading => _isLoading;
  void fetchStudents({String? className}) {
    _isLoading = true;
    notifyListeners();
    _studentSubscription?.cancel();
    _studentSubscription = _firestoreService.getStudents(className: className).listen((studentList) {
      _students = studentList;
      _isLoading = false;
      notifyListeners();
    });
  }
  void clear() {
    _studentSubscription?.cancel();
    _studentSubscription = null;
    _students = [];
    _isLoading = false;
    notifyListeners();
  }
  @override
  void dispose() {
    _studentSubscription?.cancel();
    super.dispose();
  }
  Future<void> addStudent(StudentModel student, {String? docId}) async {
    await _firestoreService.addStudent(student, docId: docId);
  }
  Future<void> updateStudent(String id, Map<String, dynamic> data) async {
    await _firestoreService.updateStudent(id, data);
  }
  Future<void> deleteStudent(String id) async {
    await _firestoreService.deleteStudent(id);
  }
}