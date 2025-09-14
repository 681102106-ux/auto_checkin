import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_record.dart';
import '../models/student_profile.dart';
import '../models/user_role.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- ฟังก์ชันหลักที่ AuthGate ใช้ "ฟัง" การเปลี่ยนแปลง ---
  Stream<DocumentSnapshot<Map<String, dynamic>>> userDocumentStream(
    String uid,
  ) {
    return _db.collection('users').doc(uid).snapshots();
  }

  // --- ฟังก์ชันสำหรับหน้าประวัติของนักเรียน ---
  Stream<List<AttendanceRecord>> getStudentAttendanceHistory(
    String studentUid,
  ) {
    return _db
        .collectionGroup('attendance_records')
        .where('studentUid', isEqualTo: studentUid)
        .orderBy('checkInTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AttendanceRecord.fromFirestore(doc))
              .toList(),
        );
  }

  // --- ฟังก์ชันสำหรับหน้าเช็คชื่อของอาจารย์ ---
  Stream<List<AttendanceRecord>> getAttendanceStream(String courseId) {
    return _db
        .collection('courses')
        .doc(courseId)
        .collection('attendance_records')
        .orderBy('checkInTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AttendanceRecord.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> updateAttendanceStatus({
    required String courseId,
    required String recordId,
    required String newStatus,
  }) async {
    await _db
        .collection('courses')
        .doc(courseId)
        .collection('attendance_records')
        .doc(recordId)
        .update({'status': newStatus});
  }

  // --- ฟังก์ชันที่เกี่ยวข้องกับการสร้าง/อัปเดตโปรไฟล์ ---
  Future<StudentProfile> getStudentProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return StudentProfile.fromFirestore(doc);
    } catch (e) {
      print("Error getting student profile: $e");
      rethrow;
    }
  }

  Future<void> createUserRecord({
    required String uid,
    required String email,
    UserRole role = UserRole.student,
  }) async {
    await _db.collection('users').doc(uid).set({
      'email': email,
      'role': role.toString().split('.').last,
      'profileComplete': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
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
    await _db.collection('users').doc(uid).update({
      'studentId': studentId,
      'fullName': fullName,
      'faculty': faculty,
      'major': major,
      'year': year,
      'phoneNumber': phoneNumber,
      'profileComplete': true,
    });
  }

  Future<void> createAttendanceRecord({
    required String courseId,
    required AttendanceRecord record,
  }) async {
    await _db
        .collection('courses')
        .doc(courseId)
        .collection('attendance_records')
        .add(record.toJson());
  }
}
