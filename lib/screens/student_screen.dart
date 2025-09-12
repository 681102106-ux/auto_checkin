import 'package:flutter/material.dart';
import 'qr_scanner_screen.dart'; // <<<--- Import หน้าสแกนเข้ามา

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  // --- [โค้ดใหม่] ฟังก์ชันสำหรับแสดง Pop-up ยืนยันการเช็คชื่อ ---
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
            Text('You are checking into class: $classCode'),
            const SizedBox(height: 16),
            TextField(
              controller: studentIdController,
              decoration: const InputDecoration(labelText: 'Your Student ID'),
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
              // TODO: Implement actual check-in logic
              final studentId = studentIdController.text;
              final studentName = studentNameController.text;
              print(
                'Checked in! Class: $classCode, ID: $studentId, Name: $studentName',
              );

              Navigator.of(context).pop(); // ปิด Pop-up

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
  // --- [จบโค้ดใหม่] ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ... (ส่วนของ Icon และ Text ต้อนรับเหมือนเดิม) ...
              const Icon(Icons.school_outlined, size: 100, color: Colors.teal),
              const SizedBox(height: 20),
              const Text(
                'Welcome, Student!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // --- [โค้ดใหม่] ปุ่มสำหรับเริ่มสแกน ---
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
                  // เปิดหน้าสแกน และ "รอ" ผลลัพธ์ (รหัสที่สแกนได้) กลับมา
                  final scannedCode = await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                      builder: (context) => const QrScannerScreen(),
                    ),
                  );

                  // ถ้ารหัสที่สแกนได้ไม่ใช่ค่าว่าง
                  if (scannedCode != null && scannedCode.isNotEmpty) {
                    // ให้แสดง Pop-up ยืนยัน
                    _showCheckInDialog(scannedCode);
                  }
                },
              ),
              // --- [จบโค้ดใหม่] ---
            ],
          ),
        ),
      ),
    );
  }
}
