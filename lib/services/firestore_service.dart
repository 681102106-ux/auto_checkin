import 'package:cloud_firestore/cloud_firestore.dart';
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
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return StudentProfile.fromFirestore(doc);
    } else {
      throw Exception('User profile not found');
    }
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
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final roleString = doc.data()!['role'] as String?;
        return UserRole.values.firstWhere(
          (e) => e.toString() == 'UserRole.$roleString',
          orElse: () =>
              UserRole.student, // Default role if not found or invalid
        );
      }
    } catch (e) {
      // In case of error, default to student role
    }
    return UserRole.student;
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
