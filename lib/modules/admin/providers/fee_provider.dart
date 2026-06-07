import 'package:flutter/material.dart';
import 'package:smart_school_unified/models/fee_model.dart';
import 'package:smart_school_unified/services/firebase/firestore_service.dart';
class FeeProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  double _totalFees = 0;
  double _collectedFees = 0;
  bool _isLoading = false;
  double get totalFees => _totalFees;
  double get collectedFees => _collectedFees;
  bool get isLoading => _isLoading;
  Future<void> loadFeeStats() async {
    _isLoading = true;
    notifyListeners();
    try {
      _totalFees = await _firestoreService.getTotalFees();
      _collectedFees = await _firestoreService.getCollectedFees();
    } catch (e) {
      debugPrint('Error loading fee stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> addFee(FeeModel fee) async {
    await _firestoreService.addFee(fee);
    await loadFeeStats();
  }
  Stream<List<FeeModel>> getFees(String? status) {
    return _firestoreService.getFees(status: status);
  }
}