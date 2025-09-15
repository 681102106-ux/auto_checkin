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

  // เราจะใช้ StreamBuilder เพื่อให้หน้านี้อัปเดตเองเมื่อ Course มีการเปลี่ยนแปลง
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
            children: [
              // --- ส่วนที่ 1: รายชื่อนักเรียนที่รออนุมัติ ---
              _buildSectionTitle(
                'Pending Approval (${course.pendingStudents.length})',
              ),
              FutureBuilder<List<StudentProfile>>(
                future: _firestoreService.getStudentsByUids(
                  course.pendingStudents,
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const SizedBox.shrink(); // ไม่ต้องแสดง loading
                  final pending = snapshot.data!;
                  if (pending.isEmpty)
                    return const ListTile(title: Text('No pending requests.'));

                  return Column(
                    children: pending
                        .map(
                          (student) => ListTile(
                            title: Text(student.fullName),
                            subtitle: Text(student.studentId),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    tooltip: 'Approve',
                                  ),
                                  onPressed: () {
                                    _firestoreService.removeStudentFromPending(
                                      course.id,
                                      student.uid,
                                    );
                                    _firestoreService.addStudentToCourse(
                                      course.id,
                                      student.uid,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                    tooltip: 'Deny',
                                  ),
                                  onPressed: () => _firestoreService
                                      .removeStudentFromPending(
                                        course.id,
                                        student.uid,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              const Divider(thickness: 2),

              // --- ส่วนที่ 2: รายชื่อนักเรียนที่อนุมัติแล้ว ---
              _buildSectionTitle(
                'Enrolled Students (${course.studentUids.length})',
              ),
              Expanded(
                child: FutureBuilder<List<StudentProfile>>(
                  future: _firestoreService.getStudentsByUids(
                    course.studentUids,
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const Center(child: CircularProgressIndicator());
                    final enrolled = snapshot.data!;
                    if (enrolled.isEmpty)
                      return const Center(child: Text('No students enrolled.'));

                    return ListView.builder(
                      itemCount: enrolled.length,
                      itemBuilder: (context, index) {
                        final student = enrolled[index];
                        return ListTile(
                          title: Text(student.fullName),
                          subtitle: Text(student.studentId),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.redAccent,
                              tooltip: 'Remove',
                            ),
                            onPressed: () =>
                                _firestoreService.removeStudentFromCourse(
                                  course.id,
                                  student.uid,
                                ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
