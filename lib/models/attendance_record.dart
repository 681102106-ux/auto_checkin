import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  final String studentUid;
  final String studentId;
  final String studentName;
  final Timestamp checkInTime;

  AttendanceRecord({
    required this.studentUid,
    required this.studentId,
    required this.studentName,
    required this.checkInTime,
  });

  // เครื่องมือแปลง Object เป็น Map เพื่อส่งให้ Firestore
  Map<String, dynamic> toJson() {
    return {
      'studentUid': studentUid,
      'studentId': studentId,
      'studentName': studentName,
      'checkInTime': checkInTime,
    };
  }
}
