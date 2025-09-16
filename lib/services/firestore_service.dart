import 'package:auto_checkin/models/checkin_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_checkin/models/course.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// "สุดยอดเชฟ" ที่จัดการทุกอย่างเกี่ยวกับ Firestore
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- USER PROFILE MANAGEMENT ---
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

  // --- COURSE MANAGEMENT (for Professors) ---
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

  // Note: Add logic is handled in create_course_screen.dart
  // Note: Update logic can be added here in the future

  Future<void> deleteCourse(String courseId) {
    // In a production app, a Cloud Function is recommended to delete subcollections.
    return _firestore.collection('courses').doc(courseId).delete();
  }

  // --- SESSION & ATTENDANCE MANAGEMENT ---
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

  Stream<QuerySnapshot> getLiveAttendanceStream(
    String courseId,
    String sessionId,
  ) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('sessions')
        .doc(sessionId)
        .collection('attendance')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // --- STUDENT-SPECIFIC FUNCTIONS ---
  Stream<List<Course>> getEnrolledCoursesStream(String studentUid) {
    return _firestore
        .collection('courses')
        .where('studentUids', arrayContains: studentUid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList();
        });
  }

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
    // Using set() prevents duplicate check-ins for the same student in the same session.
    await attendanceRef.set({
      'student_name': student.displayName ?? student.email,
      'student_uid': student.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'present',
    });
  }
}
