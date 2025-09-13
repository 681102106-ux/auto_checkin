import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_role.dart'; // Import UserRole เข้ามา

class FirestoreService {
  // สร้าง "ทางเชื่อม" ไปยัง Firestore
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- ฟังก์ชันสำหรับ "สร้างข้อมูล User" ตอนสมัครสมาชิก ---
  Future<void> createUser({
    required String uid,
    required String email,
    required UserRole role,
  }) async {
    // เราจะสร้าง "เอกสาร" (Document) ของ User ใหม่
    // ใน "คอลเลกชัน" (Collection) ที่ชื่อว่า 'users'
    // โดยใช้ uid ของ User เป็นชื่อเอกสาร
    await _db.collection('users').doc(uid).set({
      'email': email,
      // แปลง enum ให้เป็น String ก่อนเก็บข้อมูล
      'role': role.toString().split('.').last,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // --- ฟังก์ชันสำหรับ "อ่านข้อมูล Role" ของ User ---
  Future<UserRole> getUserRole(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        final roleString = doc.data()?['role'] ?? 'student';
        if (roleString == 'professor') {
          return UserRole.professor;
        }
      }
      return UserRole.student; // ถ้าไม่เจอข้อมูล ให้ถือว่าเป็น student
    } catch (e) {
      print(e);
      return UserRole.student; // กรณีเกิด Error
    }
  }
}
