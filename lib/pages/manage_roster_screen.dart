import 'package:auto_checkin/models/course.dart';
import 'package:auto_checkin/pages/generate_qr_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageRosterScreen extends StatefulWidget {
  final Course course;

  const ManageRosterScreen({Key? key, required this.course}) : super(key: key);

  @override
  _ManageRosterScreenState createState() => _ManageRosterScreenState();
}

class _ManageRosterScreenState extends State<ManageRosterScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isCreatingSession = false;

  // --- ฟังก์ชันใหม่: สำหรับสร้างคาบเรียน ---
  Future<void> _startNewSession() async {
    setState(() {
      _isCreatingSession = true;
    });

    try {
      // 1. สร้างเอกสาร "คาบเรียน" ใหม่ใน subcollection 'sessions'
      final newSessionRef = await _firestore
          .collection('courses')
          .doc(widget.course.id)
          .collection('sessions')
          .add({
            'createdAt': FieldValue.serverTimestamp(),
            // ในอนาคตเราสามารถเพิ่มข้อมูลอื่นๆ ได้ เช่น วันที่, เวลาหมดอายุ
          });

      // 2. นำ ID ของคาบเรียนที่เพิ่งสร้าง ไปเปิดหน้า QR Code
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GenerateQRScreen(
            courseId: widget.course.id,
            courseName: widget.course.name,
            sessionId: newSessionRef.id, // ส่ง Session ID ที่ได้มาใหม่ไปด้วย
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to start session: $e')));
    } finally {
      setState(() {
        _isCreatingSession = false;
      });
    }
  }

  // --- ส่วน Logic เดิม (ยังคงไว้ แต่เราจะกลับมาปรับปรุงในเฟสต่อไป) ---
  Future<void> _approveStudent(String studentDocId) async {
    try {
      await _firestore
          .collection('courses')
          .doc(widget.course.id)
          .collection('roster')
          .doc(studentDocId)
          .update({'status': 'present'});

      await _firestore.collection('courses').doc(widget.course.id).update({
        'studentUids': FieldValue.arrayUnion([studentDocId]),
      });
    } catch (e) {
      // Handle error
    }
  }

  Stream<QuerySnapshot> _getPendingStudents() {
    return _firestore
        .collection('courses')
        .doc(widget.course.id)
        .collection('roster')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  Widget _buildStudentList(Stream<QuerySnapshot> stream) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No pending requests'));
        }
        // ... (UI เดิม)
        return ListView(
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['student_name'] ?? 'No Name'),
              trailing: IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () => _approveStudent(doc.id),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.course.name)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isCreatingSession
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Start New Check-in Session'),
                    onPressed: _startNewSession,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Pending Approvals', // เราจะเปลี่ยนส่วนนี้ในเฟสต่อไป
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: _buildStudentList(_getPendingStudents())),
        ],
      ),
    );
  }
}
