import 'package:auto_checkin/pages/scan_qr_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final student = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;

  // Stream ที่ดึงข้อมูลวิชาที่นักเรียนลงทะเบียนและเช็คชื่อแล้ว
  Stream<QuerySnapshot> _getCheckedInCourses() {
    if (student == null) {
      return const Stream.empty();
    }
    // ใช้ collectionGroup query เพื่อค้นหาใน subcollection 'roster' ของทุก 'courses'
    return db
        .collectionGroup('roster')
        .where('student_uid', isEqualTo: student!.uid)
        .where('status', isEqualTo: 'present')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 50, color: Colors.deepPurple),
                ),
                const SizedBox(height: 10),
                Text(
                  student?.email ?? 'Student',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'My Checked-in Courses',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getCheckedInCourses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('You have not checked into any courses yet.'),
                  );
                }

                final courses = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final data = courses[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        title: Text(
                          data['student_name'] ?? 'Course Name Missing',
                        ),
                        subtitle: Text(
                          'Checked in at: ${DateTime.now().toLocal()}',
                        ), // Placeholder time
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScanQRScreen()),
          );
        },
        label: const Text('Scan QR'),
        icon: const Icon(Icons.qr_code_scanner),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
