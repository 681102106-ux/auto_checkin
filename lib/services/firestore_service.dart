import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course.dart';
import '../models/student_profile.dart';
import '../models/user_role.dart';
import '../models/attendance_record.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _coursesCollection = 'courses';
  final String _usersCollection = 'users';

  // --- [ฟังก์ชันใหม่!] เพิ่มนักเรียนเข้าคลาส ---
  Future<void> addStudentToCourse(String courseId, String studentUid) async {
    // ใช้ arrayUnion เพื่อเพิ่ม UID ใหม่เข้าไปในลิสต์โดยไม่ซ้ำ
    await _db.collection(_coursesCollection).doc(courseId).update({
      'studentUids': FieldValue.arrayUnion([studentUid]),
    });
  }

  // --- [ฟังก์ชันใหม่!] ลบนักเรียนออกจากคลาส ---
  Future<void> removeStudentFromCourse(
    String courseId,
    String studentUid,
  ) async {
    // ใช้ arrayRemove เพื่อลบ UID ที่ต้องการออกจากลิสต์
    await _db.collection(_coursesCollection).doc(courseId).update({
      'studentUids': FieldValue.arrayRemove([studentUid]),
    });
  }

  // --- [ฟังก์ชันใหม่!] ดึงโปรไฟล์ของนักเรียนหลายๆ คนจาก UID ---
  Future<List<StudentProfile>> getStudentsByUids(List<String> uids) async {
    if (uids.isEmpty) return []; // ถ้าไม่มี UID ก็ส่งลิสต์ว่างกลับไป
    final snapshot = await _db
        .collection(_usersCollection)
        .where(FieldPath.documentId, whereIn: uids)
        .get();
    return snapshot.docs
        .map((doc) => StudentProfile.fromFirestore(doc))
        .toList();
  }

  // ... (โค้ดเก่าทั้งหมดเหมือนเดิม) ...
  Stream<DocumentSnapshot<Map<String, dynamic>>> userDocumentStream(
    String uid,
  ) {
    return _db.collection('users').doc(uid).snapshots();
  }

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

  Future<bool> isUserProfileComplete(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists || (doc.data()?['profileComplete'] ?? false) == false) {
        return false;
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

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
