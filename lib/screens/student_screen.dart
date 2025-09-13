import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:auto_checkin/screens/login_screen.dart'; // <<<--- 1. Import หน้า Login เข้ามา
import 'qr_scanner_screen.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final _debugQrController = TextEditingController();

  // --- [โค้ดใหม่] ฟังก์ชันสำหรับแสดง Pop-up ยืนยันการ Logout ---
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
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }
  // --- [จบโค้ดใหม่] ---

  void _showCheckInDialog(String classCode) {
    final studentIdController = TextEditingController();
    final studentNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Check-in'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You are checking into class:\n$classCode',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: studentIdController,
              decoration: const InputDecoration(labelText: 'Your Student ID'),
              autofocus: true,
            ),
            TextField(
              controller: studentNameController,
              decoration: const InputDecoration(labelText: 'Your Name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final studentId = studentIdController.text;
              final studentName = studentNameController.text;
              print(
                'Checked in! Class: $classCode, ID: $studentId, Name: $studentName',
              );

              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Check-in successful!')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        // --- [โค้ดใหม่] เพิ่มปุ่ม Action สำหรับ Logout ---
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutConfirmationDialog,
            tooltip: 'Logout',
          ),
        ],
        // --- [จบโค้ดใหม่] ---
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
