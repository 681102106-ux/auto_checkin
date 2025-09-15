import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final String name;
  final String professorId;
  final String professorName;
  final bool isInviteEnabled;
  final List<String> studentUids; // เพิ่ม field ใหม่สำหรับเก็บรายชื่อนักเรียน

  Course({
    required this.id,
    required this.name,
    required this.professorId,
    required this.professorName,
    required this.isInviteEnabled,
    this.studentUids = const [], // กำหนดค่าเริ่มต้นเป็น array ว่าง
  });

  factory Course.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Course(
      id: doc.id,
      name: data['name'] ?? '',
      professorId: data['professorId'] ?? '',
      professorName: data['professorName'] ?? '',
      isInviteEnabled: data['isInviteEnabled'] ?? false,
      // แปลงข้อมูลจาก Firestore ให้เป็น List<String>
      studentUids: List<String>.from(data['studentUids'] ?? []),
    );
  }

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
