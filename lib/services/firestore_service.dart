import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_checkin/models/course.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- ฟังก์ชันเดิม ---
  Stream<List<Course>> getEnrolledCoursesStream(String studentUid) {
    return _firestore
        .collection('courses')
        .where('studentUids', arrayContains: studentUid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList();
        });
  }

  // --- ฟังก์ชันใหม่: สร้างโปรไฟล์ User ถ้ายังไม่มี ---
  Future<void> createUserProfileIfNeeded(User user) async {
    final userDocRef = _firestore.collection('users').doc(user.uid);
    final doc = await userDocRef.get();

    // ตรวจสอบว่ามี "ทะเบียนบ้าน" ของ User คนนี้แล้วหรือยัง
    if (!doc.exists) {
      // ถ้ายังไม่มี ให้สร้างขึ้นมาใหม่
      await userDocRef.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'student', // <-- กำหนด Role เริ่มต้นให้ทุกคนเป็น student
      });
    }
  }

  // --- ฟังก์ชันใหม่: ดึงข้อมูลโปรไฟล์ของ User ---
  Future<DocumentSnapshot> getUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).get();
  }
}
