import 'package:auto_checkin/models/course.dart';
import 'package:auto_checkin/models/student_profile.dart';
import 'package:auto_checkin/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageRosterScreen extends StatefulWidget {
  final Course course;
  const ManageRosterScreen({super.key, required this.course});

  @override
  State<ManageRosterScreen> createState() => _ManageRosterScreenState();
}

class _ManageRosterScreenState extends State<ManageRosterScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage: ${widget.course.name}')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _firestoreService.getCourseStream(widget.course.id),
        builder: (context, courseSnapshot) {
          if (!courseSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final course = Course.fromFirestore(courseSnapshot.data!);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- ส่วนที่ 1: รายชื่อนักเรียนที่รออนุมัติ ---
              _buildSectionTitle(
                'Pending Approval (${course.pendingStudents.length})',
              ),
              _buildStudentList(
                course.pendingStudents,
                isPendingList: true,
                courseId: course.id,
              ),

              const Divider(thickness: 2),

              // --- ส่วนที่ 2: รายชื่อนักเรียนที่อนุมัติแล้ว ---
              _buildSectionTitle(
                'Enrolled Students (${course.studentUids.length})',
              ),
              Expanded(
                child: _buildStudentList(
                  course.studentUids,
                  isPendingList: false,
                  courseId: course.id,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- [Widget ใหม่!] สร้าง Widget แยกสำหรับแสดงลิสต์ ---
  Widget _buildStudentList(
    List<String> studentUids, {
    required bool isPendingList,
    required String courseId,
  }) {
    if (studentUids.isEmpty) {
      return ListTile(
        title: Text(
          isPendingList ? 'No pending requests.' : 'No students enrolled.',
        ),
      );
    }

    return FutureBuilder<List<StudentProfile>>(
      future: _firestoreService.getStudentsByUids(studentUids),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final students = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true, // ทำให้ ListView สูงเท่าที่จำเป็น
          physics:
              const NeverScrollableScrollPhysics(), // ปิดการเลื่อนของ ListView ย่อย
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return ListTile(
              title: Text(student.fullName),
              subtitle: Text(student.studentId),
              trailing: isPendingList
                  ? _buildPendingActions(courseId, student.uid)
                  : _buildEnrolledActions(courseId, student.uid),
            );
          },
        );
      },
    );
  }

  Row _buildPendingActions(String courseId, String studentUid) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.check_circle, color: Colors.green),
          tooltip: 'Approve',
          onPressed: () {
            _firestoreService.removeStudentFromPending(courseId, studentUid);
            _firestoreService.addStudentToCourse(courseId, studentUid);
          },
        ),
        IconButton(
          icon: const Icon(Icons.cancel, color: Colors.red),
          tooltip: 'Deny',
          onPressed: () =>
              _firestoreService.removeStudentFromPending(courseId, studentUid),
        ),
      ],
    );
  }

  IconButton _buildEnrolledActions(String courseId, String studentUid) {
    return IconButton(
      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
      tooltip: 'Remove',
      onPressed: () =>
          _firestoreService.removeStudentFromCourse(courseId, studentUid),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
