import 'package:auto_checkin/pages/scan_qr_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Import for kDebugMode
import 'package:flutter/material.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({Key? key}) : super(key: key);

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _debugQrController = TextEditingController();

  // ฟังก์ชันสำหรับแสดง Dialog ยืนยันการเช็คชื่อ
  Future<void> _showCheckInDialog(String courseId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // ดึงข้อมูลคอร์สเพื่อแสดงชื่อ
    final courseDoc = await _firestore
        .collection('courses')
        .doc(courseId)
        .get();
    if (!courseDoc.exists) {
      _showError("Course not found.");
      return;
    }
    final courseName = courseDoc.data()?['name'] ?? 'Unknown Course';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Check-in'),
          content: Text('Do you want to check in to "$courseName"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                _performCheckIn(courseId, user);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันสำหรับบันทึกข้อมูลการเช็คชื่อ
  Future<void> _performCheckIn(String courseId, User user) async {
    try {
      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('roster')
          .doc(user.uid)
          .set({
            'student_name': user.displayName ?? user.email,
            'student_id':
                user.uid, // You can use another student ID if available
            'status': 'pending', // สถานะเริ่มต้นคือรอการอนุมัติ
            'timestamp': FieldValue.serverTimestamp(),
          });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Check-in request sent!')));
    } catch (e) {
      _showError("Failed to send check-in request: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _debugQrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _auth.signOut(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${user?.displayName ?? user?.email ?? 'Student'}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan QR to Check-in'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () async {
                // รอรับผลลัพธ์จากหน้าสแกน
                final scannedCode = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanQRScreen()),
                );
                if (scannedCode != null && scannedCode.isNotEmpty) {
                  _showCheckInDialog(scannedCode);
                }
              },
            ),
            const SizedBox(height: 40),
            // --- เครื่องมือสำหรับนักพัฒนา ---
            if (kDebugMode)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const Text('--- DEBUGGER ---'),
                    TextField(
                      controller: _debugQrController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Course ID to Simulate Scan',
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        final simulatedCode = _debugQrController.text;
                        if (simulatedCode.isNotEmpty) {
                          _showCheckInDialog(simulatedCode);
                        }
                      },
                      child: const Text('Simulate Scan'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
