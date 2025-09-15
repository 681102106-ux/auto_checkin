import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_checkin/models/course.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/checkin_session.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- ฟังก์ชันสำหรับ User ---
  Future<void> createUserProfileIfNeeded(User user) async {
    final userDocRef = _firestore.collection('users').doc(user.uid);
    final doc = await userDocRef.get();
    if (!doc.exists) {
      await userDocRef.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'student',
      });
    }
  }

  Future<DocumentSnapshot> getUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).get();
  }

  // --- ฟังก์ชันสำหรับ Professor ---

  /// ดึงรายชื่อคอร์สทั้งหมดสำหรับอาจารย์คนนั้นๆ
  Stream<List<Course>> getCoursesStreamForProfessor(String professorId) {
    return _firestore
        .collection('courses')
        .where('professorId', isEqualTo: professorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList(),
        );
  }

  /// ลบคอร์สเรียน
  Future<void> deleteCourse(String courseId) {
    return _firestore.collection('courses').doc(courseId).delete();
  }

  // --- ฟังก์ชันสำหรับ Session และ Attendance ---

  /// สร้างคาบเรียนใหม่และคืนค่า ID ของ Session
  Future<String> startNewCheckinSession(String courseId) async {
    final newSessionRef = await _firestore
        .collection('courses')
        .doc(courseId)
        .collection('sessions')
        .add({
          'courseId': courseId,
          'startTime': FieldValue.serverTimestamp(),
          'isActive': true,
        });
    return newSessionRef.id;
  }

  /// Stream รายการคาบเรียนทั้งหมดของคลาสเรียนหนึ่งๆ
  Stream<List<CheckinSession>> getCourseSessionsStream(String courseId) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('sessions')
        .orderBy('startTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CheckinSession.fromFirestore(doc))
              .toList(),
        );
  }

  // --- ฟังก์ชันสำหรับ Student ---

  /// Stream รายชื่อคอร์สที่นักเรียนลงทะเบียนไว้
  Stream<List<Course>> getEnrolledCoursesStream(String studentUid) {
    return _firestore
        .collection('courses')
        .where('studentUids', arrayContains: studentUid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList();
        });
  }

  /// บันทึกการเข้าเรียนของนักเรียนในคาบเรียน (Session)
  Future<void> createAttendanceRecord({
    required String courseId,
    required String sessionId,
    required User student,
  }) async {
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
  }
}
