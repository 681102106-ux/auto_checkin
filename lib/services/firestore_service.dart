import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_checkin/models/course.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get a stream of courses a student is enrolled in
  Stream<List<Course>> getEnrolledCoursesStream(String studentUid) {
    // นี่คือ "เมนู" ใหม่ที่เราสร้างขึ้นครับ
    // มันจะไปหาคอร์สทั้งหมดที่มี UID ของนักเรียนคนนี้อยู่ในรายชื่อ
    return _firestore
        .collection('courses')
        .where('studentUids', arrayContains: studentUid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList();
        });
  }
}
