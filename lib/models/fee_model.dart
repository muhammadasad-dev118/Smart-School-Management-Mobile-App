import 'package:cloud_firestore/cloud_firestore.dart';
class FeeModel {
  final String id;
  final String studentId;
  final String studentName;
  final String className;
  final String rollNumber;
  final double amount;
  final String status;
  final String description;
  final DateTime dueDate;
  final DateTime? paidDate;
  final DateTime createdAt;
  FeeModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.rollNumber,
    required this.amount,
    required this.status,
    required this.description,
    required this.dueDate,
    this.paidDate,
    required this.createdAt,
  });
  factory FeeModel.fromMap(Map<String, dynamic> map, String id) {
    return FeeModel(
      id: id,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      className: map['className'] ?? '',
      rollNumber: map['rollNumber'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      description: map['description'] ?? '',
      dueDate: (map['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paidDate: (map['paidDate'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'className': className,
      'rollNumber': rollNumber,
      'amount': amount,
      'status': status,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
  String get initials {
    final parts = studentName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return studentName.isNotEmpty ? studentName[0].toUpperCase() : '?';
  }
}