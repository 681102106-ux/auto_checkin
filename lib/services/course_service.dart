import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course.dart';

class CourseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionName = 'courses';

  // --- [เปลี่ยน] จาก getCourses() ธรรมดา เป็น Stream ที่คอย "ฟัง" การเปลี่ยนแปลง ---
  Stream<List<Course>> getCoursesStream(String professorId) {
    // ไปที่ collection 'courses' และกรองเอาเฉพาะคลาสที่ professorId ตรงกัน
    return _db
        .collection(_collectionName)
        .where('professorId', isEqualTo: professorId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList(),
        );
  }

  // --- [เปลี่ยน] ฟังก์ชันเพิ่มคลาส ให้ทำงานกับ Firestore ---
  Future<void> addCourse(Course course) {
    return _db.collection(_collectionName).add(course.toJson());
  }

  // --- [เปลี่ยน] ฟังก์ชันอัปเดตคลาส ให้ทำงานกับ Firestore ---
  Future<void> updateCourse(Course course) {
    return _db
        .collection(_collectionName)
        .doc(course.id)
        .update(course.toJson());
  }

  // --- [ใหม่] ฟังก์ชันลบคลาส ---
  Future<void> deleteCourse(String courseId) {
    return _db.collection(_collectionName).doc(courseId).delete();
  }
}
