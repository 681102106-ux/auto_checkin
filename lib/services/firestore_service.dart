import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_record.dart';
import '../models/course.dart';
import '../models/student_profile.dart';
import '../models/user_role.dart';

class FirestoreService {
  Stream<DocumentSnapshot<Map<String, dynamic>>> getCourseStream(
    String courseId,
  ) {
    return _db.collection(_coursesCollection).doc(courseId).snapshots();
  }

  Future<void> removeStudentFromPending(
    String courseId,
    String studentUid,
  ) async {
    await _db.collection(_coursesCollection).doc(courseId).update({
      'pendingStudents': FieldValue.arrayRemove([studentUid]),
    });
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _coursesCollection = 'courses';
  final String _usersCollection = 'users';

  Stream<DocumentSnapshot<Map<String, dynamic>>> getCourseStream(
    String courseId,
  ) {
    return _db.collection(_coursesCollection).doc(courseId).snapshots();
  }

  Future<List<StudentProfile>> getStudentsInCourse(
    List<String> studentUids,
  ) async {
    if (studentUids.isEmpty) {
      return []; // ถ้าไม่มีนักเรียนในทะเบียน ก็ส่งลิสต์ว่างกลับไป
    }
    // ไปค้นหาใน 'users' collection โดยใช้ UID ทั้งหมดที่อยู่ในทะเบียน
    final snapshot = await _db
        .collection(_usersCollection)
        .where(FieldPath.documentId, whereIn: studentUids)
        .get();

    return snapshot.docs
        .map((doc) => StudentProfile.fromFirestore(doc))
        .toList();
  }

  // --- [ฟังก์ชันใหม่!] ดึงข้อมูลคลาสเดียวจาก ID ---
  Future<Course?> getCourseById(String courseId) async {
    try {
      final doc = await _db.collection(_coursesCollection).doc(courseId).get();
      if (doc.exists) {
        return Course.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting course by ID: $e');
      return null;
    }
  }
  // --- [จบฟังก์ชันใหม่] ---

  Future<void> addStudentToCourse(String courseId, String studentUid) async {
    await _db.collection(_coursesCollection).doc(courseId).update({
      'studentUids': FieldValue.arrayUnion([studentUid]),
    });
  }

  Future<void> removeStudentFromCourse(
    String courseId,
    String studentUid,
  ) async {
    await _db.collection(_coursesCollection).doc(courseId).update({
      'studentUids': FieldValue.arrayRemove([studentUid]),
    });
  }

  Future<List<StudentProfile>> getStudentsByUids(List<String> uids) async {
    if (uids.isEmpty) return [];
    final snapshot = await _db
        .collection(_usersCollection)
        .where(FieldPath.documentId, whereIn: uids)
        .get();
    return snapshot.docs
        .map((doc) => StudentProfile.fromFirestore(doc))
        .toList();
  }

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
