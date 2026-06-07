class TeacherModuleTeacherModel {
  final String id;
  final String name;
  final String email;
  final List<String> assignedClasses;
  final String subject;
  final String phone;
  TeacherModuleTeacherModel({
    required this.id,
    required this.name,
    required this.email,
    required this.assignedClasses,
    required this.subject,
    required this.phone,
  });
  factory TeacherModuleTeacherModel.fromMap(Map<String, dynamic> data, String id) {
    return TeacherModuleTeacherModel(
      id: id,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      assignedClasses: (data['assignedClasses'] as List?)?.map((e) => e.toString()).toList() ??
                       (data['assignedClass'] != null ? [data['assignedClass'].toString()] : []),
      subject: data['subject']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'assignedClasses': assignedClasses,
      'subject': subject,
      'phone': phone,
    };
  }
}
class TeacherModuleStudentModel {
  final String id;
  final String name;
  final String className;
  final String rollNumber;
  final String email;
  TeacherModuleStudentModel({
    required this.id,
    required this.name,
    required this.className,
    required this.rollNumber,
    required this.email,
  });
  factory TeacherModuleStudentModel.fromMap(Map<String, dynamic> data, String id) {
    return TeacherModuleStudentModel(
      id: id,
      name: data['name']?.toString() ?? '',
      className: data['className']?.toString() ?? '',
      rollNumber: data['rollNumber']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'className': className,
      'rollNumber': rollNumber,
      'email': email,
    };
  }
}