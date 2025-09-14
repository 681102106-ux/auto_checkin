import 'package:auto_checkin/models/attendance.dart'; // <<<--- 1. Import ที่จำเป็น
import 'package:auto_checkin/models/attendance_record.dart';
import 'package:auto_checkin/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentHistoryScreen extends StatelessWidget {
  const StudentHistoryScreen({super.key});

  // --- [ย้ายมาไว้ตรงนี้!] ฟังก์ชันช่วยแสดงไอคอนและสีตามสถานะ ---
  // การย้ายออกมาไว้นอก build method ทำให้มันกลายเป็นส่วนหนึ่งของ Class
  // และทำให้ Dart รู้ว่ามันเป็นสิ่งที่คงที่และเชื่อถือได้
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
  // --- [จบส่วนที่ย้ายมา] ---

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance History'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: currentUser == null
          ? const Center(child: Text('User not found.'))
          : StreamBuilder<List<AttendanceRecord>>(
              stream: FirestoreService().getStudentAttendanceHistory(
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
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: _getStatusIcon(record.status),
                        title: Text('Course ID: ${record.courseId}'),
                        subtitle: Text(
                          DateFormat(
                            'dd MMMM yyyy - HH:mm',
                          ).format(record.checkInTime.toDate()),
                        ),
                        trailing: Text(
                          record.status
                              .toString()
                              .split('.')
                              .last
                              .toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(record.status),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
