import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Future<String?> uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
  Future<String?> uploadStudentPhoto(File file, String studentId) async {
    final ext = file.path.split('.').last;
    return uploadFile(file, 'students/$studentId/profile.$ext');
  }
  Future<String?> uploadTeacherPhoto(File file, String teacherId) async {
    final ext = file.path.split('.').last;
    return uploadFile(file, 'teachers/$teacherId/profile.$ext');
  }
  Future<void> deleteFile(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {}
  }
}