import 'package:cloud_firestore/cloud_firestore.dart';
class StudentModel {
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
  final String email;
  final String password;
  final DateTime enrolledAt;
  StudentModel({
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
    required this.email,
    required this.password,
    required this.enrolledAt,
  });
  factory StudentModel.fromMap(Map<String, dynamic> map, String id) {
    return StudentModel(
      id: id,
      name: map['name']?.toString() ?? '',
      className: map['className']?.toString() ?? '',
      section: map['section']?.toString() ?? '',
      rollNumber: map['rollNumber']?.toString() ?? '',
      gender: map['gender']?.toString() ?? '',
      dateOfBirth: (map['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now(),
      guardianName: map['guardianName']?.toString() ?? '',
      guardianRelation: map['guardianRelation']?.toString() ?? '',
      guardianPhone: map['guardianPhone']?.toString() ?? '',
      guardianEmail: map['guardianEmail']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      state: map['state']?.toString() ?? '',
      zipCode: map['zipCode']?.toString() ?? '',
      photoUrl: map['photoUrl']?.toString(),
      feeStatus: map['feeStatus']?.toString() ?? 'pending',
      attendancePercentage: (map['attendancePercentage'] ?? 0.0).toDouble(),
      email: map['email']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
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
      'email': email,
      'password': password,
      'enrolledAt': Timestamp.fromDate(enrolledAt),
    };
  }
  String get displayClass => '$className-$section';
}