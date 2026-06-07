import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_school_unified/core/constants/app_constants.dart';

class DashboardProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Map<String, dynamic> _stats = {
    'students': 0,
    'teachers': 0,
    'classes': 0,
    'activeUsers': 0,
  };
  bool _isLoading = false;
  String _currentTime = '';
  Timer? _timer;
  StreamSubscription? _studentsSub;
  StreamSubscription? _teachersSub;
  StreamSubscription? _usersSub;

  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  String get currentTime => _currentTime;

  DashboardProvider() {
    _startClock();
    _startRealTimeListeners();
  }

  void _startClock() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    _currentTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    notifyListeners();
  }

  void _startRealTimeListeners() {
    _isLoading = true;
    _studentsSub = _db.collection(AppConstants.studentsCollection).snapshots().listen((snap) {
      _stats['students'] = snap.size;
      _stats['classes'] = AppConstants.classes.length;
      notifyListeners();
    });

    _teachersSub = _db.collection(AppConstants.teachersCollection).snapshots().listen((snap) {
      _stats['teachers'] = snap.size;
      notifyListeners();
    });

    _usersSub = _db.collection(AppConstants.usersCollection).snapshots().listen((snap) {
      _stats['activeUsers'] = snap.size;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> loadDashboardStats() async {
    notifyListeners();
  }

  void clear() {
    _stats = {
      'students': 0,
      'teachers': 0,
      'classes': 0,
      'activeUsers': 0,
    };
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _studentsSub?.cancel();
    _teachersSub?.cancel();
    _usersSub?.cancel();
    super.dispose();
  }
}