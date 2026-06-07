import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_school_unified/services/auth/session_service.dart';
class AdminAuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SessionService _sessionService = SessionService();
  bool _isLoggedIn = false;
  String? _adminEmail;
  bool _isSessionExpired = false;
  AdminAuthProvider() {
    _auth.setPersistence(Persistence.NONE);
    _initializeAuth();
  }
  Future<void> _initializeAuth() async {
    await _auth.signOut();
    _isLoggedIn = false;
    _adminEmail = null;
    notifyListeners();
  }
  void _startPeriodicCheck() {
    Timer.periodic(const Duration(minutes: 1), (timer) {
      if (!_isLoggedIn) {
        timer.cancel();
        return;
      }
      _checkSessionStatus();
    });
  }
  bool get isLoggedIn => _isLoggedIn;
  String? get adminEmail => _adminEmail;
  bool get isSessionExpired => _isSessionExpired;
  Future<void> _checkSessionStatus() async {
    if (_auth.currentUser == null) return;
    final expired = await _sessionService.isSessionExpired();
    final valid = await _sessionService.isSessionValid(_auth.currentUser!.uid);
    if (expired || !valid) {
      _isSessionExpired = true;
      logout();
    }
  }
  Future<bool> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (credential.user != null) {
        await _sessionService.createNewSession(credential.user!.uid);
        _isLoggedIn = true;
        _adminEmail = credential.user!.email;
        _isSessionExpired = false;
        _startPeriodicCheck();
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Login error: $e");
      rethrow;
    }
    return false;
  }
  Future<bool> signup(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (credential.user != null) {
        await _sessionService.createNewSession(credential.user!.uid);
        _isLoggedIn = true;
        _adminEmail = credential.user!.email;
        _isSessionExpired = false;
        _startPeriodicCheck();
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Signup error: $e");
      rethrow;
    }
    return false;
  }
  void logout() async {
    await _auth.signOut();
    await _sessionService.clearSession();
    _isLoggedIn = false;
    _adminEmail = null;
    notifyListeners();
  }
  Future<void> updateActivity() async {
    if (_isLoggedIn) {
      await _sessionService.updateActivity();
    }
  }
}