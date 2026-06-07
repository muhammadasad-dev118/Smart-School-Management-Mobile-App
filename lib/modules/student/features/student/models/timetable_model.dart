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
  factory TimetableModel.fromMap(Map<String, dynamic> map, String id) {
    return TimetableModel(
      id: id,
      className: map['className'] ?? '',
      section: map['section'] ?? '',
      day: map['day'] ?? '',
      subject: map['subject'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      room: map['room'] ?? '',
    );
  }
}