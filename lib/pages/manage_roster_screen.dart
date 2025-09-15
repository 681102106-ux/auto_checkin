import 'package:auto_checkin/models/course.dart';
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

  Future<void> _approveStudent(String studentDocId) async {
    try {
      // 1. อัปเดตสถานะใน roster ของคลาส
      await _firestore
          .collection('courses')
          .doc(widget.course.id)
          .collection('roster')
          .doc(studentDocId)
          .update({'status': 'present'});

      // 2. เพิ่มนักเรียนเข้าไปในทะเบียนของคอร์สหลัก
      await _firestore.collection('courses').doc(widget.course.id).update({
        'studentUids': FieldValue.arrayUnion([studentDocId]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student approved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to approve student: $e')));
    }
  }

  Future<void> _denyStudent(String studentDocId) async {
    try {
      await _firestore
          .collection('courses')
          .doc(widget.course.id)
          .collection('roster')
          .doc(studentDocId)
          .update({'status': 'denied'}); // หรือจะใช้ .delete() ก็ได้
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

  Stream<QuerySnapshot> _getEnrolledStudents() {
    return _firestore
        .collection('courses')
        .doc(widget.course.id)
        .collection('roster')
        .where('status', whereIn: ['present', 'absent'])
        .snapshots();
  }

  Widget _buildStudentList(
    Stream<QuerySnapshot> stream, {
    bool isPending = false,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              isPending ? 'No pending requests' : 'No students enrolled',
            ),
          );
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['student_name'] ?? 'No Name'),
              subtitle: Text(data['student_id'] ?? 'No ID'),
              trailing: isPending
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _approveStudent(doc.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _denyStudent(doc.id),
                        ),
                      ],
                    )
                  : Text(data['status'] ?? ''),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.course.name),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending Approval'),
              Tab(text: 'Enrolled Students'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildStudentList(_getPendingStudents(), isPending: true),
            _buildStudentList(_getEnrolledStudents()),
          ],
        ),
      ),
    );
  }
}
