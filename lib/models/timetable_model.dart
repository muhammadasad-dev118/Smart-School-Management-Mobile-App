import 'package:cloud_firestore/cloud_firestore.dart';
class TimetableModel {
  final String id;
  final String className;
  final String section;
  final String day;
  final String subject;
  final String teacherId;
  final String teacherName;
  final String startTime;
  final String endTime;
  final String room;
  TimetableModel({
    required this.id,
    required this.className,
    required this.section,
    required this.day,
    required this.subject,
    required this.teacherId,
    required this.teacherName,
    required this.startTime,
    required this.endTime,
    required this.room,
  });
  Map<String, dynamic> toMap() {
    return {
      'className': className,
      'section': section,
      'day': day,
      'subject': subject,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
    };
  }
  factory TimetableModel.fromMap(Map<String, dynamic> map, String id) {
    return TimetableModel(
      id: id,
      className: map['className']?.toString() ?? '',
      section: map['section']?.toString() ?? '',
      day: map['day']?.toString() ?? '',
      subject: map['subject']?.toString() ?? '',
      teacherId: map['teacherId']?.toString() ?? '',
      teacherName: map['teacherName']?.toString() ?? '',
      startTime: map['startTime']?.toString() ?? '',
      endTime: map['endTime']?.toString() ?? '',
      room: map['room']?.toString() ?? '',
    );
  }
}
class TimetableRequestModel {
  final String id;
  final String teacherId;
  final String teacherName;
  final String timetableId;
  final String currentSchedule;
  final String requestedSchedule;
  final String reason;
  final String status;
  final DateTime createdAt;
  TimetableRequestModel({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.timetableId,
    required this.currentSchedule,
    required this.requestedSchedule,
    required this.reason,
    required this.status,
    required this.createdAt,
  });
  Map<String, dynamic> toMap() {
    return {
      'teacherId': teacherId,
      'teacherName': teacherName,
      'timetableId': timetableId,
      'currentSchedule': currentSchedule,
      'requestedSchedule': requestedSchedule,
      'reason': reason,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
  factory TimetableRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return TimetableRequestModel(
      id: id,
      teacherId: map['teacherId']?.toString() ?? '',
      teacherName: map['teacherName']?.toString() ?? '',
      timetableId: map['timetableId']?.toString() ?? '',
      currentSchedule: map['currentSchedule']?.toString() ?? '',
      requestedSchedule: map['requestedSchedule']?.toString() ?? '',
      reason: map['reason']?.toString() ?? '',
      status: map['status']?.toString() ?? 'pending',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}