import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_school_unified/models/teacher_student_models.dart';
import 'package:smart_school_unified/core/constants/app_constants.dart';
import 'package:smart_school_unified/services/auth/teacher_session_service.dart';
class TeacherAuthProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final SessionService _sessionService = SessionService();
  TeacherModuleTeacherModel? _currentTeacher;
  bool _isLoading = false;
  bool _isSessionExpired = false;
  TeacherAuthProvider() {
    _restoreSession();
  }
  TeacherModuleTeacherModel? get currentTeacher => _currentTeacher;
  bool get isLoading => _isLoading;
  bool get isSessionExpired => _isSessionExpired;
  Future<void> setTeacherById(String id, {String? email}) async {
    try {
      DocumentSnapshot doc = await _db.collection(AppConstants.teachersCollection).doc(id).get();
      if (!doc.exists && email != null) {
        final query = await _db.collection(AppConstants.teachersCollection).where('email', isEqualTo: email.toLowerCase()).get();
        if (query.docs.isNotEmpty) {
          doc = query.docs.first;
        }
      }
      if (doc.exists) {
        _currentTeacher = TeacherModuleTeacherModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        await _sessionService.createNewSession(_currentTeacher!.id);
        _isSessionExpired = false;
        _startPeriodicCheck();
        notifyListeners();
      } else {
        debugPrint("Teacher document not found for ID: $id or Email: $email");
      }
    } catch (e) {
      debugPrint("Error setting teacher by ID: $e");
    }
  }
  Future<void> _restoreSession() async {
  }
  void _startPeriodicCheck() {
    Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_currentTeacher == null) {
        timer.cancel();
        return;
      }
      _checkSessionStatus();
    });
  }
  Future<void> _checkSessionStatus() async {
    if (_currentTeacher == null) return;
    final expired = await _sessionService.isSessionExpired();
    final valid = await _sessionService.isSessionValid(_currentTeacher!.id);
    if (expired || !valid) {
      _isSessionExpired = true;
      logout();
    }
  }
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final String normalizedEmail = email.trim().toLowerCase();
      final snapshot = await _db
          .collection(AppConstants.teachersCollection)
          .where('email', isEqualTo: normalizedEmail)
          .where('password', isEqualTo: password.trim())
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        _currentTeacher = TeacherModuleTeacherModel.fromMap(
          snapshot.docs.first.data(),
          snapshot.docs.first.id,
        );
        await _sessionService.createNewSession(_currentTeacher!.id);
        _isSessionExpired = false;
        _isLoading = false;
        _startPeriodicCheck();
        notifyListeners();
        return true;
      } else {
        debugPrint("No teacher found with email: $normalizedEmail");
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint("Detailed login error: $e");
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  Future<void> refreshProfile() async {
    if (_currentTeacher == null) return;
    try {
      final doc = await _db
          .collection(AppConstants.teachersCollection)
          .doc(_currentTeacher!.id)
          .get();
      if (doc.exists) {
        _currentTeacher = TeacherModuleTeacherModel.fromMap(doc.data()!, doc.id);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error refreshing teacher profile: $e");
    }
  }
  void logout() async {
    _currentTeacher = null;
    await _sessionService.clearSession();
    _isLoading = false;
    _isSessionExpired = false;
    notifyListeners();
  }
  Future<void> updateActivity() async {
    if (_currentTeacher != null) {
      await _sessionService.updateActivity();
    }
  }
}