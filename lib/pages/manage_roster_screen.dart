import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course.dart';

class ManageRosterScreen extends StatefulWidget {
  final Course course;

  const ManageRosterScreen({Key? key, required this.course}) : super(key: key);

  @override
  _ManageRosterScreenState createState() => _ManageRosterScreenState();
}

class _ManageRosterScreenState extends State<ManageRosterScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        .where('status', isEqualTo: 'present')
        .snapshots();
  }

  Future<void> _approveStudent(String studentDocId) async {
    try {
      await _firestore
          .collection('courses')
          .doc(widget.course.id)
          .collection('roster')
          .doc(studentDocId)
          .update({'status': 'present'});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student approved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error approving student: $e')));
    }
  }

  Future<void> _denyStudent(String studentDocId) async {
    try {
      await _firestore
          .collection('courses')
          .doc(widget.course.id)
          .collection('roster')
          .doc(studentDocId)
          .update({'status': 'absent'});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Student denied.')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error denying student: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage: ${widget.course.name}'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Pending Approval'),
            _buildPendingList(),
            const SizedBox(height: 24.0),
            _buildSectionTitle('Enrolled Students'),
            _buildEnrolledList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildPendingList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getPendingStudents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No pending requests.'),
            ),
          );
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final pendingStudents = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pendingStudents.length,
          itemBuilder: (context, index) {
            final student = pendingStudents[index];
            final studentData = student.data() as Map<String, dynamic>;
            final studentName =
                studentData['student_name'] ?? 'Unknown Student';
            final studentId = studentData['student_id'] ?? 'No ID';

            return Card(
              elevation: 2.0,
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                title: Text(studentName),
                subtitle: Text('ID: $studentId'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () => _approveStudent(student.id),
                      tooltip: 'Approve',
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => _denyStudent(student.id),
                      tooltip: 'Deny',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEnrolledList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getEnrolledStudents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No students checked in yet.'),
            ),
          );
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final enrolledStudents = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: enrolledStudents.length,
          itemBuilder: (context, index) {
            final student = enrolledStudents[index];
            final studentData = student.data() as Map<String, dynamic>;
            final studentName =
                studentData['student_name'] ?? 'Unknown Student';

            return Card(
              elevation: 2.0,
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                title: Text(studentName),
                subtitle: const Text('Status: Present'),
                leading: const Icon(Icons.person, color: Colors.deepPurple),
              ),
            );
          },
        );
      },
    );
  }
}
