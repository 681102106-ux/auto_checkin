import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course.dart';

class CourseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionName = 'courses';

  Stream<List<Course>> getCoursesStream(String professorId) {
    return _db
        .collection(_collectionName)
        .where('professorId', isEqualTo: professorId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addCourse(Course course) {
    return _db.collection(_collectionName).add(course.toJson());
  }

  Future<void> updateCourse(Course course) {
    return _db
        .collection(_collectionName)
        .doc(course.id)
        .update(course.toJson());
  }

  Future<void> deleteCourse(String courseId) {
    return _db.collection(_collectionName).doc(courseId).delete();
  }
}
