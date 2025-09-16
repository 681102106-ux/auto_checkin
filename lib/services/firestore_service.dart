import 'package:auto_checkin/models/checkin_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_checkin/models/course.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_record.dart';
import '../models/course.dart';
import '../models/student_profile.dart';
import '../models/user_role.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_checkin/models/course.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/checkin_session.dart';

/// "สุดยอดเชฟ" ที่จัดการทุกอย่างเกี่ยวกับ Firestore
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _coursesCollection = 'courses';
  final String _usersCollection = 'users';

  // --- [ย้ายมาจาก CourseService] ---
  Stream<List<Course>> getCoursesStream(String professorId) {
    return _db
        .collection(_coursesCollection)
        .where('professorId', isEqualTo: professorId)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addCourse(Course course) {
    return _db.collection(_coursesCollection).add(course.toJson());
  }

  Future<void> updateCourse(Course course) {
    return _db
        .collection(_coursesCollection)
        .doc(course.id)
        .update(course.toJson());
  }

  // --- [แก้ไข!] ฟังก์ชันลบที่ทำงานกับ Firestore จริงๆ ---
  Future<void> deleteCourse(String courseId) {
    return _db.collection(_coursesCollection).doc(courseId).delete();
  }
  // --- [จบส่วนที่ย้ายมา] ---

  // --- [ฟังก์ชันใหม่!] ค้นหาคลาสทั้งหมดที่นักเรียนลงทะเบียน ---
  Stream<List<Course>> getEnrolledCoursesStream(String studentUid) {
    return _firestore
        .collection('courses')
        .where('studentUids', arrayContains: studentUid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList();
        });
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

  Stream<List<AttendanceRecord>> getLiveAttendanceStream(
    String courseId,
    String sessionId,
  ) {
    return _db
        .collection('courses')
        .doc(courseId)
        .collection('sessions')
        .doc(sessionId)
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
    required String sessionId,
    required String recordId,
    required String newStatus,
  }) async {
    await _db
        .collection('courses')
        .doc(courseId)
        .collection('sessions')
        .doc(sessionId)
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
    required String sessionId,
    required User student,
  }) async {
    // --- ส่วนที่ 1: บันทึกการเข้าเรียนในคาบเรียน (เหมือนเดิม) ---
    final attendanceRef = _firestore
        .collection('courses')
        .doc(courseId)
        .collection('sessions')
        .doc(sessionId)
        .collection('attendance')
        .doc(student.uid);

    await attendanceRef.set({
      'student_name': student.displayName ?? student.email,
      'student_uid': student.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'present',
    });

    // --- ส่วนที่ 2: เพิ่มโค้ดเพื่ออัปเดต "ทะเบียนหลัก" ของคอร์ส ---
    // นี่คือส่วนที่เพิ่มเข้ามาเพื่อแก้ปัญหา "ชั้นหนังสือ" ไม่อัปเดต
    final courseRef = _firestore.collection('courses').doc(courseId);
    await courseRef.update({
      // FieldValue.arrayUnion จะเพิ่ม UID ของนักเรียนเข้าไปใน List
      // โดยอัตโนมัติ และจะป้องกันการเพิ่มชื่อซ้ำให้ด้วย
      'studentUids': FieldValue.arrayUnion([student.uid]),
    });
  }

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

  Stream<DocumentSnapshot<Map<String, dynamic>>> getCourseStream(
    String courseId,
  ) {
    return _db.collection(_coursesCollection).doc(courseId).snapshots();
  }

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

  Future<void> removeStudentFromPending(
    String courseId,
    String studentUid,
  ) async {
    await _db.collection(_coursesCollection).doc(courseId).update({
      'pendingStudents': FieldValue.arrayRemove([studentUid]),
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
}
