import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_school_unified/services/auth/student_session_service.dart';
import 'package:smart_school_unified/modules/student/features/student/models/student_model.dart';
class StudentAuthProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final SessionService _sessionService = SessionService();
  StudentModuleStudentModel? _currentStudent;
  bool _isLoading = false;
  bool _isSessionExpired = false;
  StudentAuthProvider();
  StudentModuleStudentModel? get currentStudent => _currentStudent;
  bool get isLoading => _isLoading;
  bool get isSessionExpired => _isSessionExpired;
  Future<void> setStudentById(String id, {String? email}) async {
    try {
      DocumentSnapshot doc = await _db.collection('students').doc(id).get();
      if (!doc.exists && email != null) {
        final query = await _db.collection('students').where('email', isEqualTo: email.toLowerCase()).get();
        if (query.docs.isNotEmpty) {
          doc = query.docs.first;
        }
      }
      if (doc.exists) {
        _currentStudent = StudentModuleStudentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        await _sessionService.createNewSession(id);
        _isSessionExpired = false;
        _startPeriodicCheck();
        notifyListeners();
      } else {
        debugPrint("Student document not found for ID: $id or Email: $email");
      }
    } catch (e) {
      debugPrint("Error setting student by ID: $e");
    }
  }
  void _startPeriodicCheck() {
    Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_currentStudent == null) {
        timer.cancel();
        return;
      }
      _checkSessionStatus();
    });
  }
  Future<void> _checkSessionStatus() async {
    if (_currentStudent == null) return;
    final expired = await _sessionService.isSessionExpired();
    final valid = await _sessionService.isSessionValid(_currentStudent!.id);
    if (expired || !valid) {
      _isSessionExpired = true;
      logout();
    }
  }
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _db
          .collection('students')
          .where('email', isEqualTo: email.trim())
          .where('password', isEqualTo: password.trim())
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        _currentStudent = StudentModuleStudentModel.fromMap(doc.data(), doc.id);
        await _sessionService.createNewSession(_currentStudent!.id);
        _isSessionExpired = false;
        _isLoading = false;
        _startPeriodicCheck();
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  void logout() async {
    _currentStudent = null;
    await _sessionService.clearSession();
    _isLoading = false;
    _isSessionExpired = false;
    notifyListeners();
  }
  Future<void> updateActivity() async {
    if (_currentStudent != null) {
      await _sessionService.updateActivity();
    }
  }
  Future<void> requestPasswordReset(String email, String message) async {
    try {
      await _db.collection('admin_notifications').add({
        'type': 'Password Reset / Support',
        'email': email.trim(),
        'message': message.trim(),
        'status': 'Unread',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error sending support request: $e');
      rethrow;
    }
  }
}