import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_school_unified/services/auth/auth_service.dart';
import 'package:smart_school_unified/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _user;
  bool _isLoading = false;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      UserCredential? credential;
      final trimmedEmail = email.trim();
      final lowercaseEmail = trimmedEmail.toLowerCase();
      try {
        credential = await _authService.signIn(trimmedEmail, password);
      } catch (authError) {
        debugPrint("DEBUG: Auth failed, checking Firestore for $trimmedEmail...");
        var teacherQuery =
            await _firestore
                .collection('teachers')
                .where('email', isEqualTo: lowercaseEmail)
                .where('password', isEqualTo: password.trim())
                .get();
        if (teacherQuery.docs.isEmpty) {
          teacherQuery =
              await _firestore
                  .collection('teachers')
                  .where('email', isEqualTo: trimmedEmail)
                  .where('password', isEqualTo: password.trim())
                  .get();
        }
        if (teacherQuery.docs.isNotEmpty) {
          debugPrint("DEBUG: Found teacher in Firestore, auto-creating account...");
          await _authService.createAccount(trimmedEmail, password.trim());
          credential = await _authService.signIn(trimmedEmail, password.trim());
        } else {
          var studentQuery =
              await _firestore
                  .collection('students')
                  .where('email', isEqualTo: lowercaseEmail)
                  .where('password', isEqualTo: password.trim())
                  .get();
          if (studentQuery.docs.isEmpty) {
            studentQuery =
                await _firestore
                    .collection('students')
                    .where('email', isEqualTo: trimmedEmail)
                    .where('password', isEqualTo: password.trim())
                    .get();
          }
          if (studentQuery.docs.isNotEmpty) {
            debugPrint("DEBUG: Found student in Firestore, auto-creating account...");
            await _authService.createAccount(trimmedEmail, password.trim());
            credential = await _authService.signIn(
              trimmedEmail,
              password.trim(),
            );
          } else {
            throw 'Invalid email or password.';
          }
        }
      }
      final user = credential.user;
      if (user != null) {
        String role = 'admin';
        Map<String, dynamic> userData = {};
        final teacherQuery =
            await _firestore
                .collection('teachers')
                .where('email', isEqualTo: user.email?.toLowerCase())
                .get();
        if (teacherQuery.docs.isNotEmpty) {
          role = 'teacher';
          final doc = teacherQuery.docs.first;
          userData = doc.data();
          if (doc.id != user.uid) {
            debugPrint("DEBUG: Migrating teacher doc ${doc.id} to UID ${user.uid}");
            await _firestore.collection('teachers').doc(user.uid).set(userData);
            await _firestore.collection('teachers').doc(doc.id).delete();
          }
        } else {
          final studentQuery =
              await _firestore
                  .collection('students')
                  .where('email', isEqualTo: user.email?.toLowerCase())
                  .get();
          if (studentQuery.docs.isNotEmpty) {
            role = 'student';
            final doc = studentQuery.docs.first;
            userData = doc.data();
            if (doc.id != user.uid) {
              debugPrint("DEBUG: Migrating student doc ${doc.id} to UID ${user.uid}");
              await _firestore
                  .collection('students')
                  .doc(user.uid)
                  .set(userData);
              await _firestore.collection('students').doc(doc.id).delete();
            }
          } else {
            final adminDoc =
                await _firestore.collection('users').doc(user.uid).get();
            if (adminDoc.exists) {
              role = 'admin';
              userData = adminDoc.data()!;
            }
          }
        }
        _user = UserModel(
          uid: user.uid,
          email: email.trim().toLowerCase(),
          role: role,
          name: userData['name'] ?? userData['fullName'] ?? 'User',
          createdAt:
              (userData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  Future<void> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.resetPassword(email);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
  void setUser(UserModel? user) {
    _user = user;
    notifyListeners();
  }
}