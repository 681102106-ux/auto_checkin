import 'package:auto_checkin/models/course.dart';
import 'package:auto_checkin/pages/scan_qr_screen.dart';
import 'package:auto_checkin/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class StudentScreen extends StatefulWidget {
  const StudentScreen({Key? key}) : super(key: key);
  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _debugQrController = TextEditingController();

  Future<void> _handleScannedCode(String scannedCode) async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final data = jsonDecode(scannedCode) as Map<String, dynamic>;
      final courseId = data['courseId'] as String?;
      final sessionId = data['sessionId'] as String?;
      if (courseId == null || sessionId == null) throw 'Invalid QR Data';
      await _firestoreService.createAttendanceRecord(
        courseId: courseId,
        sessionId: sessionId,
        student: user,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check-in successful!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('QR Code Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _debugQrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text("...")));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _auth.signOut),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- ส่วนที่ 1: Action Buttons ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan QR to Check-in'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () async {
                final scannedCode = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanQRScreen()),
                );
                if (scannedCode != null) _handleScannedCode(scannedCode);
              },
            ),
          ),
          // --- เครื่องมือ Debug ---
          if (kDebugMode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text("--- DEBUGGER ---"),
                      TextField(
                        controller: _debugQrController,
                        decoration: const InputDecoration(
                          labelText: 'Paste QR Data',
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            _handleScannedCode(_debugQrController.text),
                        child: const Text('Simulate Scan'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // --- ส่วนที่ 2: ชั้นหนังสือ ---
          const Divider(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'My Enrolled Courses',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Course>>(
              stream: _firestoreService.getEnrolledCoursesStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty)
                  return const Center(
                    child: Text("You are not enrolled in any courses."),
                  );
                final courses = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.school_outlined),
                        title: Text(course.name),
                        subtitle: Text(course.professorName),
                      ),
                      // onTap: () => /* View course details */,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
