import 'package:cloud_firestore/cloud_firestore.dart';
class StudentModuleStudentModel {
  final String id;
  final String name;
  final String className;
  final String section;
  final String rollNumber;
  final String gender;
  final DateTime dateOfBirth;
  final String guardianName;
  final String guardianRelation;
  final String guardianPhone;
  final String guardianEmail;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String? photoUrl;
  final String feeStatus;
  final double attendancePercentage;
  final DateTime enrolledAt;
  StudentModuleStudentModel({
    required this.id,
    required this.name,
    required this.className,
    required this.section,
    required this.rollNumber,
    required this.gender,
    required this.dateOfBirth,
    required this.guardianName,
    required this.guardianRelation,
    required this.guardianPhone,
    required this.guardianEmail,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    this.photoUrl,
    this.feeStatus = 'pending',
    this.attendancePercentage = 0.0,
    required this.enrolledAt,
  });
  factory StudentModuleStudentModel.fromMap(Map<String, dynamic> map, String id) {
    return StudentModuleStudentModel(
      id: id,
      name: map['name'] ?? '',
      className: map['className'] ?? '',
      section: map['section'] ?? '',
      rollNumber: map['rollNumber'] ?? '',
      gender: map['gender'] ?? '',
      dateOfBirth: (map['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now(),
      guardianName: map['guardianName'] ?? '',
      guardianRelation: map['guardianRelation'] ?? '',
      guardianPhone: map['guardianPhone'] ?? '',
      guardianEmail: map['guardianEmail'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zipCode: map['zipCode'] ?? '',
      photoUrl: map['photoUrl'],
      feeStatus: map['feeStatus'] ?? 'pending',
      attendancePercentage: (map['attendancePercentage'] ?? 0.0).toDouble(),
      enrolledAt: (map['enrolledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'className': className,
      'section': section,
      'rollNumber': rollNumber,
      'gender': gender,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'guardianName': guardianName,
      'guardianRelation': guardianRelation,
      'guardianPhone': guardianPhone,
      'guardianEmail': guardianEmail,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'photoUrl': photoUrl,
      'feeStatus': feeStatus,
      'attendancePercentage': attendancePercentage,
      'enrolledAt': Timestamp.fromDate(enrolledAt),
    };
  }
}