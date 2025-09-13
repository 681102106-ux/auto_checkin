import 'package:auto_checkin/screens/student_profile_screen.dart'; // <<<--- Import เข้ามา
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'qr_scanner_screen.dart';

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

  // ... (ฟังก์ชัน _showLogoutConfirmationDialog และ _showCheckInDialog เหมือนเดิม) ...
  void _showLogoutConfirmationDialog() {
    /* ... */
  }
  void _showCheckInDialog(String classCode) {
    /* ... */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          // --- [โค้ดใหม่] เพิ่มปุ่ม Profile ---
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
          // ---------------------------------
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
                // ... (ส่วนของ Debug Tool เหมือนเดิม) ...
              ],
            ],
          ),
        ),
      ),
    );
  }
}
