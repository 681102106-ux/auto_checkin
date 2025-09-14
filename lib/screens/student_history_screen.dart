import 'package:auto_checkin/models/attendance.dart';
import 'package:auto_checkin/models/attendance_record.dart';
import 'package:auto_checkin/models/course.dart';
import 'package:auto_checkin/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentHistoryScreen extends StatelessWidget {
  const StudentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance History'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: currentUser == null
          ? const Center(child: Text('User not found.'))
          : StreamBuilder<List<AttendanceRecord>>(
              stream: firestoreService.getStudentAttendanceHistory(
                currentUser.uid,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No attendance history found.'),
                  );
                }

                final records = snapshot.data!;

                return ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    // --- [แก้ไข] เปลี่ยนจาก ListTile ธรรมดา เป็น Widget ใหม่ของเรา ---
                    return CourseHistoryTile(record: record);
                  },
                );
              },
            ),
    );
  }
}

// --- [Widget ใหม่!] ที่จะไปดึงชื่อคลาสมาแสดงเอง ---
class CourseHistoryTile extends StatelessWidget {
  final AttendanceRecord record;
  const CourseHistoryTile({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Course?>(
      // เรียกใช้ "เมนูใหม่" ของพ่อครัว
      future: FirestoreService().getCourseById(record.courseId),
      builder: (context, snapshot) {
        // ถ้าโหลดชื่อคลาสสำเร็จ ให้แสดงชื่อเต็ม
        // ถ้าไม่สำเร็จ หรือกำลังโหลด ให้แสดงแค่ Course ID ไปก่อน
        final courseName =
            snapshot.data?.name ?? 'Course ID: ${record.courseId}';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: _getStatusIcon(record.status),
            title: Text(
              courseName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              DateFormat(
                'dd MMMM yyyy - HH:mm',
              ).format(record.checkInTime.toDate()),
            ),
            trailing: Text(
              record.status.toString().split('.').last.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getStatusColor(record.status),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- ฟังก์ชันช่วยแสดงไอคอนและสีตามสถานะ ---
  Icon _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return const Icon(Icons.check_circle, color: Colors.green);
      case AttendanceStatus.absent:
        return const Icon(Icons.cancel, color: Colors.red);
      case AttendanceStatus.onLeave:
        return const Icon(Icons.description, color: Colors.orange);
      case AttendanceStatus.late:
        return const Icon(Icons.watch_later, color: Colors.blueGrey);
      default:
        return const Icon(Icons.help, color: Colors.grey);
    }
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.onLeave:
        return Colors.orange;
      case AttendanceStatus.late:
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }
}
