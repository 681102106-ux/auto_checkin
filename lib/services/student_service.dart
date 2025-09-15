import 'package:cloud_firestore/cloud_firestore.dart';

class StudentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _coursesCollection = 'courses';

  Future<String> joinCourseWithCode({
    required String studentUid,
    required String joinCode,
  }) async {
    try {
      final querySnapshot = await _db
          .collection(_coursesCollection)
          .where('joinCode', isEqualTo: joinCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return 'Invalid join code.'; // ไม่เจอคลาส
      }

      final courseDoc = querySnapshot.docs.first;
      final courseData = courseDoc.data();

      // --- [ใหม่!] ตรวจสอบว่าคลาสเปิดรับสมัครไหม ---
      if (courseData['joinCodeEnabled'] == false) {
        return 'This class is not accepting new members.';
      }

      // --- [แก้ไข!] เปลี่ยนจากการเพิ่มตรงๆ เป็นการส่งคำขอ ---
      await courseDoc.reference.update({
        'pendingStudents': FieldValue.arrayUnion([studentUid]),
      });

      return 'Request sent successfully! Please wait for professor approval.'; // ส่งคำขอสำเร็จ!
    } catch (e) {
      print('Error joining course: $e');
      return 'An error occurred. Please try again.'; // ล้มเหลว
    }
  }
}
