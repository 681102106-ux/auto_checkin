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
      // --- [ผ่าตัดใหญ่!] ใช้ StreamBuilder เป็นหัวใจหลัก ---
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        // "เงี่ยหูฟัง" การเปลี่ยนแปลงของคลาสนี้โดยตรง
        stream: _firestoreService.getCourseStream(widget.course.id),
        builder: (context, courseSnapshot) {
          if (!courseSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final course = Course.fromFirestore(courseSnapshot.data!);

          // --- [ใช้ FutureBuilder] เพื่อดึงข้อมูลโปรไฟล์ทั้งหมดในครั้งเดียว ---
          return FutureBuilder<Map<String, List<StudentProfile>>>(
            // เราจะดึงข้อมูล "รออนุมัติ" และ "อนุมัติแล้ว" มาพร้อมกันเลย
            future:
                Future.wait([
                  _firestoreService.getStudentsByUids(course.pendingStudents),
                  _firestoreService.getStudentsByUids(course.studentUids),
                ]).then(
                  (results) => {'pending': results[0], 'enrolled': results[1]},
                ),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!profileSnapshot.hasData) {
                return const Center(child: Text('Loading student data...'));
              }
              final pendingStudents = profileSnapshot.data!['pending']!;
              final enrolledStudents = profileSnapshot.data!['enrolled']!;

              return CustomScrollView(
                slivers: [
                  // --- ส่วนที่ 1: รายชื่อนักเรียนที่รออนุมัติ ---
                  SliverToBoxAdapter(
                    child: _buildSectionTitle(
                      'Pending Approval (${pendingStudents.length})',
                    ),
                  ),
                  _buildStudentSliverList(
                    pendingStudents,
                    isPendingList: true,
                    courseId: course.id,
                  ),

                  const SliverToBoxAdapter(child: Divider(thickness: 2)),

                  // --- ส่วนที่ 2: รายชื่อนักเรียนที่อนุมัติแล้ว ---
                  SliverToBoxAdapter(
                    child: _buildSectionTitle(
                      'Enrolled Students (${enrolledStudents.length})',
                    ),
                  ),
                  _buildStudentSliverList(
                    enrolledStudents,
                    isPendingList: false,
                    courseId: course.id,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // --- [Widget ใหม่!] สร้าง Widget แยกสำหรับแสดงลิสต์ใน CustomScrollView ---
  Widget _buildStudentSliverList(
    List<StudentProfile> students, {
    required bool isPendingList,
    required String courseId,
  }) {
    if (students.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            isPendingList ? 'No pending requests.' : 'No students enrolled.',
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final student = students[index];
        return ListTile(
          title: Text(student.fullName),
          subtitle: Text(student.studentId),
          trailing: isPendingList
              ? _buildPendingActions(courseId, student.uid)
              : _buildEnrolledActions(courseId, student.uid),
        );
      }, childCount: students.length),
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
