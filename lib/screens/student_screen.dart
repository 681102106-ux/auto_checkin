import 'package:auto_checkin/models/attendance_record.dart'; // <<<--- Import เข้ามา
import 'package:auto_checkin/models/student_profile.dart';
import 'package:auto_checkin/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <<<--- Import เพิ่ม
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'qr_scanner_screen.dart';
import 'student_profile_screen.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final _debugQrController = TextEditingController();

  @override
  void dispose() {
    _debugQrController.dispose();
    super.dispose();
  }

  void _showLogoutConfirmationDialog() {
    /* ... โค้ดส่วนนี้เหมือนเดิม ... */
  }

  void _showCheckInDialog(String classCode) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Check-in'),
          content: FutureBuilder<StudentProfile>(
            future: FirestoreService().getStudentProfile(currentUser.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return const Text("Could not load profile. Please try again.");
              }
              final profile = snapshot.data!;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Class Code: $classCode'),
                  const Divider(height: 20),
                  Text('Name: ${profile.fullName}'),
                  Text('Student ID: ${profile.studentId}'),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // --- [ผ่าตัดใหญ่!] เปลี่ยน Logic การ Confirm ---
                final profile = await FirestoreService().getStudentProfile(
                  currentUser.uid,
                );

                final record = AttendanceRecord(
                  studentUid: currentUser.uid,
                  studentId: profile.studentId,
                  studentName: profile.fullName,
                  checkInTime: Timestamp.now(), // บันทึกเวลาที่กดปุ่ม
                );

                // เรียกพ่อครัวมาบันทึกข้อมูล
                await FirestoreService().createAttendanceRecord(
                  courseId: classCode, // classCode ที่สแกนมาคือ ID ของคลาส
                  record: record,
                );

                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Check-in successful!')),
                  );
                }
                // --- [จบการผ่าตัด] ---
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... โค้ด UI ของ build() เหมือนเดิมเป๊ะ ...
  }
}
