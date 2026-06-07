import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class SessionService {
  static const String _lastActivityKey = 'last_activity';
  static const String _sessionIdKey = 'session_id';
  static const int sessionTimeoutMinutes = 15;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> updateActivity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastActivityKey, DateTime.now().millisecondsSinceEpoch);
  }
  Future<bool> isSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActivity = prefs.getInt(_lastActivityKey);
    if (lastActivity == null) return false;
    final diff = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastActivity));
    return diff.inMinutes >= sessionTimeoutMinutes;
  }
  Future<void> createNewSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    await prefs.setString(_sessionIdKey, sessionId);
    await prefs.setInt(_lastActivityKey, DateTime.now().millisecondsSinceEpoch);
    await _firestore.collection('teacher_sessions').doc(userId).set({
      'activeSessionId': sessionId,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }
  Future<bool> isSessionValid(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final localSessionId = prefs.getString(_sessionIdKey);
    if (localSessionId == null) return false;
    final doc = await _firestore.collection('teacher_sessions').doc(userId).get();
    if (!doc.exists) return false;
    final remoteSessionId = doc.data()?['activeSessionId'];
    return localSessionId == remoteSessionId;
  }
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastActivityKey);
    await prefs.remove(_sessionIdKey);
  }
}