import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_checkin/models/attendance.dart'; // <<<--- Import เข้ามา

class AttendanceRecord {
  final String id; // <<<--- เพิ่ม ID ของเอกสาร
  final String studentUid;
  final String studentId;
  final String studentName;
  final Timestamp checkInTime;
  final AttendanceStatus status;

  AttendanceRecord({
    required this.id,
    required this.studentUid,
    required this.studentId,
    required this.studentName,
    required this.checkInTime,
    required this.status,
  });

  // เครื่องมือแปลง Object เป็น Map เพื่อส่งให้ Firestore
  Map<String, dynamic> toJson() {
    return {
      'studentUid': studentUid,
      'studentId': studentId,
      'studentName': studentName,
      'checkInTime': checkInTime,
      'status': status.toString().split('.').last, // เก็บเป็น String
    };
  }

  factory AttendanceRecord.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    // แปลง String กลับเป็น enum
    final statusString = data['status'] ?? 'unknown';
    final status = AttendanceStatus.values.firstWhere(
      (e) => e.toString().split('.').last == statusString,
      orElse: () => AttendanceStatus.unknown,
    );

    return AttendanceRecord(
      id: doc.id,
      studentUid: data['studentUid'] ?? '',
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      checkInTime: data['checkInTime'] ?? Timestamp.now(),
      status: status,
    );
  }
}
