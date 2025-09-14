import 'package.cloud_firestore/cloud_firestore.dart';
import '../models/attendance_record.dart'; // <<<--- Import เข้ามา
import '../models/student_profile.dart';
import '../models/user_role.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>> userDocumentStream(
    String uid,
  ) {
    return _db.collection('users').doc(uid).snapshots();
  }

  // --- [ฟังก์ชันใหม่!] บันทึกการเช็คชื่อ ---
  Future<void> createAttendanceRecord({
    required String courseId,
    required AttendanceRecord record,
  }) async {
    // เราจะสร้าง "สมุดเช็คชื่อ" (subcollection) ใหม่ในคลาสนั้นๆ
    // แล้วเพิ่ม "บันทึก" (document) ของนักเรียนคนนี้เข้าไป
    await _db
        .collection('courses')
        .doc(courseId)
        .collection('attendance_records')
        .add(record.toJson());
  }
  // --- [จบฟังก์ชันใหม่] ---

  Future<StudentProfile> getStudentProfile(String uid) async {
    // ... โค้ดส่วนนี้เหมือนเดิม ...
  }

  // ... โค้ดส่วนอื่นทั้งหมดเหมือนเดิม ...
  Future<void> createUserRecord({
    required String uid,
    required String email,
    UserRole role = UserRole.student,
  }) async {
    /* ... */
  }
  Future<UserRole> getUserRole(String uid) async {
    /* ... */
  }
  Future<void> updateStudentProfile({
    required String uid,
    required String studentId,
    required String fullName,
    required String faculty,
    required String major,
    required int year,
    required String phoneNumber,
  }) async {
    /* ... */
  }
}
