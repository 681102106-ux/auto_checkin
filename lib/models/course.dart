import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final String name;
  final String description;
  final String professorId;
  final bool isInviteEnabled; // เพิ่ม field นี้

  Course({
    required this.id,
    required this.name,
    required this.description,
    required this.professorId,
    required this.isInviteEnabled, // เพิ่มใน constructor
  });

  factory Course.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Course(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      professorId: data['professorId'] ?? '',
      // ดึงค่า isInviteEnabled ถ้าไม่มีให้เป็น true (เปิดใช้งานเป็นค่าเริ่มต้น)
      isInviteEnabled: data['isInviteEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'professorId': professorId,
      'isInviteEnabled': isInviteEnabled, // เพิ่มใน map
    };
  }
}
