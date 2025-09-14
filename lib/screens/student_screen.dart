import 'package:auto_checkin/models/attendance_record.dart'; // <<<--- 1. หยิบแบบฟอร์มเข้ามา
import 'package:auto_checkin/models/student_profile.dart';
import 'package:auto_checkin/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <<<--- 2. หยิบนาฬิกาเข้ามา
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

  // โค้ดส่วนนี้เหมือนเดิม
  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text('Are you sure you want to log out?')],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
                FirebaseAuth.instance.signOut();
              },
            ),
          ],
        );
      },
    );
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
                // ตอนนี้โค้ดส่วนนี้จะทำงานได้สมบูรณ์แล้ว
                final profile = await FirestoreService().getStudentProfile(
                  currentUser.uid,
                );

                final record = AttendanceRecord(
                  id: '', // ไม่ต้องใช้ ID ตอนสร้าง
                  studentUid: currentUser.uid,
                  studentId: profile.studentId,
                  studentName: profile.fullName,
                  checkInTime: Timestamp.now(),
                  status: AttendanceStatus.present, // <<<--- เพิ่มสถานะเริ่มต้น
                );
                await FirestoreService().createAttendanceRecord(
                  courseId: classCode,
                  record: record,
                );

                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Check-in successful!')),
                  );
                }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const StudentProfileScreen(),
                ),
              );
            },
            tooltip: 'My Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutConfirmationDialog,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school_outlined, size: 100, color: Colors.teal),
              const SizedBox(height: 20),
              const Text(
                'Welcome, Student!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan QR to Check-in'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () async {
                  final scannedCode = await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                      builder: (context) => const QrScannerScreen(),
                    ),
                  );
                  if (scannedCode != null && scannedCode.isNotEmpty) {
                    _showCheckInDialog(scannedCode);
                  }
                },
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 40),
                const Text('--- DEBUG ONLY ---'),
                TextField(
                  controller: _debugQrController,
                  decoration: const InputDecoration(
                    labelText: 'Paste QR Code Data Here',
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  child: const Text('Simulate Scan'),
                  onPressed: () {
                    final fakeScannedCode = _debugQrController.text;
                    if (fakeScannedCode.isNotEmpty) {
                      _showCheckInDialog(fakeScannedCode);
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
