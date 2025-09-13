import 'package.cloud_firestore/cloud_firestore.dart';
import '../models/user_role.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUserRecord({
    required String uid,
    required String email,
    UserRole role = UserRole.student, // <<<--- ค่าเริ่มต้นคือ student เสมอ
  }) async {
    await _db.collection('users').doc(uid).set({
      'email': email,
      'role': role.toString().split('.').last,
      'profileComplete': false, // <<<--- เพิ่มสถานะว่ายังกรอกข้อมูลไม่เสร็จ
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<UserRole> getUserRole(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        final roleString = doc.data()?['role'] ?? 'student';
        return roleString == 'professor'
            ? UserRole.professor
            : UserRole.student;
      }
      return UserRole.student;
    } catch (e) {
      print(e);
      return UserRole.student;
    }
  }

  // --- [ฟังก์ชันใหม่] เช็กว่าโปรไฟล์สมบูรณ์หรือยัง ---
  Future<bool> isUserProfileComplete(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      // ถ้าไม่มีเอกสาร หรือ 'profileComplete' เป็น false หรือไม่มีอยู่ ให้ถือว่าไม่สมบูรณ์
      if (!doc.exists || (doc.data()?['profileComplete'] ?? false) == false) {
        return false;
      }
      return true;
    } catch (e) {
      print(e);
      return false; // ถ้า Error ให้ถือว่าไม่สมบูรณ์
    }
  }

  // --- [ฟังก์ชันใหม่] อัปเดตข้อมูลโปรไฟล์นักศึกษา ---
  Future<void> updateStudentProfile({
    required String uid,
    required String studentId,
    required String fullName,
    required String faculty,
    required String major,
    required int year,
    required String phoneNumber,
  }) async {
    // เราจะใช้ `update` เพื่อเพิ่มข้อมูลเข้าไปในเอกสารเดิม
    await _db.collection('users').doc(uid).update({
      'studentId': studentId,
      'fullName': fullName,
      'faculty': faculty,
      'major': major,
      'year': year,
      'phoneNumber': phoneNumber,
      'profileComplete': true, // <<<--- อัปเดตสถานะว่ากรอกข้อมูลเสร็จแล้ว
    });
  }
}
