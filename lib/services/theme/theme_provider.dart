import 'package:flutter/material.dart';
import 'package:smart_school_unified/services/firebase/firestore_service.dart';
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  final FirestoreService _firestoreService = FirestoreService();
  ThemeMode get themeMode => _themeMode;
  ThemeProvider() {
    _loadTheme();
  }
  Future<void> _loadTheme() async {
    final config = await _firestoreService.getSchoolConfig();
    final themeStr = config['theme'] ?? 'Light';
    _setThemeMode(themeStr);
  }
  void _setThemeMode(String themeStr) {
    if (themeStr == 'Dark') {
      _themeMode = ThemeMode.dark;
    } else if (themeStr == 'Light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }
  Future<void> setTheme(String themeStr) async {
    _setThemeMode(themeStr);
    await _firestoreService.updateSchoolConfig({'theme': themeStr});
  }
}