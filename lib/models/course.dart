import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final String name;
  final String professorId;
  final String professorName;
  final bool isInviteEnabled;
  final List<String> studentUids;

  Course({
    required this.id,
    required this.name,
    required this.professorId,
    required this.professorName,
    required this.isInviteEnabled,
    this.studentUids = const [],
  });

  factory Course.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Course(
      id: doc.id,
      name: data['name'] ?? '',
      professorId: data['professorId'] ?? '',
      professorName: data['professorName'] ?? '',
      isInviteEnabled: data['isInviteEnabled'] ?? false,
      studentUids: List<String>.from(data['studentUids'] ?? []),
    );
  }

  // --- ส่วนที่เพิ่มเข้ามา ---
  // เพิ่มฟังก์ชัน toMap (ที่ถูกเรียกผิดเป็น toJson ใน error)
  // เพื่อแปลงข้อมูล Course object กลับเป็น Map สำหรับ Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'professorId': professorId,
      'professorName': professorName,
      'isInviteEnabled': isInviteEnabled,
      'studentUids': studentUids,
    };
  }
}
