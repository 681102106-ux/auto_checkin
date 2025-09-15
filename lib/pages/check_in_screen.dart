import 'dart:convert';
import 'package:auto_checkin/models/course.dart';
import 'package:auto_checkin/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CheckInScreen extends StatefulWidget {
  final Course course;
  final String sessionId;

  const CheckInScreen({Key? key, required this.course, required this.sessionId})
    : super(key: key);

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    // เข้ารหัสข้อมูลสำหรับ QR Code
    final qrData = jsonEncode({
      'courseId': widget.course.id,
      'sessionId': widget.sessionId,
    });

    return Scaffold(
      appBar: AppBar(title: Text("Live Session: ${widget.course.name}")),
      body: Column(
        children: [
          // ส่วนแสดง QR Code
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.grey.shade100,
            child: Center(
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 200.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Students: Scan this code to check-in!",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const Divider(thickness: 1),
          // ส่วนแสดงผล Live
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Live Attendance",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: _firestoreService.getLiveAttendanceStream(
                    widget.course.id,
                    widget.sessionId,
                  ),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return Chip(
                      label: Text(
                        "$count Students",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      avatar: const Icon(Icons.people),
                      backgroundColor: Colors.green.shade100,
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getLiveAttendanceStream(
                widget.course.id,
                widget.sessionId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("Waiting for students to check in..."),
                  );
                }
                final attendanceDocs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: attendanceDocs.length,
                  itemBuilder: (context, index) {
                    final doc = attendanceDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      leading: CircleAvatar(
                        child: const Icon(Icons.person_outline),
                        backgroundColor: Colors.grey.shade200,
                      ),
                      title: Text(data['student_name'] ?? 'Unknown Student'),
                      trailing: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 28,
                      ),
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
