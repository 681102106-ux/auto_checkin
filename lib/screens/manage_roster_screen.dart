import 'package:auto_checkin/models/course.dart';
import 'package:auto_checkin/models/student_profile.dart';
import 'package:auto_checkin/services/firestore_service.dart';
import 'package:flutter/material.dart';

class ManageRosterScreen extends StatefulWidget {
  final Course course;
  const ManageRosterScreen({super.key, required this.course});

  @override
  State<ManageRosterScreen> createState() => _ManageRosterScreenState();
}

class _ManageRosterScreenState extends State<ManageRosterScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _studentUidController = TextEditingController();

  void _addStudent() {
    if (_studentUidController.text.isNotEmpty) {
      _firestoreService.addStudentToCourse(
        widget.course.id,
        _studentUidController.text.trim(),
      );
      _studentUidController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage: ${widget.course.name}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _studentUidController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Student UID',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: _addStudent,
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<List<StudentProfile>>(
              stream: _firestoreService
                  .getStudentsByUids(widget.course.studentUids)
                  .asStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final students = snapshot.data!;
                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return ListTile(
                      title: Text(student.fullName),
                      subtitle: Text(student.studentId),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        ),
                        onPressed: () =>
                            _firestoreService.removeStudentFromCourse(
                              widget.course.id,
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
      ),
    );
  }
}
