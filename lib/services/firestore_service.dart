import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_profile.dart'; // <<<--- ตรวจสอบ import นี้ให้ถูกต้อง
import '../models/user_role.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>> userDocumentStream(
    String uid,
  ) {
    return _db.collection('users').doc(uid).snapshots();
  }

  // --- [ฟังก์ชันใหม่] ดึงข้อมูลโปรไฟล์ของนักเรียน ---
  Future<StudentProfile> getStudentProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return StudentProfile.fromFirestore(doc);
    } catch (e) {
      print("Error getting student profile: $e");
      rethrow;
    }
  }
  // --- [จบฟังก์ชันใหม่] ---

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
}
