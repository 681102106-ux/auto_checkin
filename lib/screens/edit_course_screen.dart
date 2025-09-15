import 'package:auto_checkin/services/course_service.dart';
import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/scoring_rules.dart';

class EditCourseScreen extends StatefulWidget {
  final Course course;

  const EditCourseScreen({super.key, required this.course});

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _courseNameController;
  late TextEditingController _profNameController;
  late ScoringRules _scoringRules;
  late bool _joinCodeEnabled; // เพิ่ม State สำหรับสวิตช์

  @override
  void initState() {
    super.initState();
    _courseNameController = TextEditingController(text: widget.course.name);
    _profNameController = TextEditingController(
      text: widget.course.professorName,
    );
    _scoringRules = ScoringRules.fromJson(widget.course.scoringRules.toJson());
    _joinCodeEnabled = widget.course.joinCodeEnabled;
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _profNameController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedCourse = Course(
        id: widget.course.id,
        name: _courseNameController.text,
        professorName: _profNameController.text,
        professorId: widget.course.professorId,
        scoringRules: _scoringRules,
        joinCode: widget
            .course
            .joinCode, // <<<--- [จุดแก้ไข!] เพิ่ม joinCode เดิมเข้าไป
        joinCodeEnabled: _joinCodeEnabled, // <<<--- เพิ่มค่าจากสวิตช์
        studentUids: widget.course.studentUids,
        pendingStudents: widget.course.pendingStudents,
      );

      CourseService().updateCourse(updatedCourse).then((_) {
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Course')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _courseNameController,
              decoration: const InputDecoration(labelText: 'Course Name'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a name' : null,
            ),
            TextFormField(
              controller: _profNameController,
              decoration: const InputDecoration(labelText: 'Professor Name'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a name' : null,
            ),
            const Divider(height: 32),
            // --- เพิ่มสวิตช์เปิด/ปิดรหัสเชิญ ---
            SwitchListTile(
              title: const Text('Enable Join Code'),
              value: _joinCodeEnabled,
              onChanged: (bool value) {
                setState(() {
                  _joinCodeEnabled = value;
                });
              },
            ),
            const Divider(height: 32),
            Text(
              'Scoring Rules',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextFormField(
              initialValue: _scoringRules.presentScore.toString(),
              decoration: const InputDecoration(labelText: 'Present Score'),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  _scoringRules.presentScore = double.tryParse(value) ?? 1.0,
            ),
            TextFormField(
              initialValue: _scoringRules.absentScore.toString(),
              decoration: const InputDecoration(labelText: 'Absent Score'),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  _scoringRules.absentScore = double.tryParse(value) ?? 0.0,
            ),
            TextFormField(
              initialValue: _scoringRules.onLeaveScore.toString(),
              decoration: const InputDecoration(labelText: 'On Leave Score'),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  _scoringRules.onLeaveScore = double.tryParse(value) ?? 0.5,
            ),
            TextFormField(
              initialValue: _scoringRules.lateScore.toString(),
              decoration: const InputDecoration(labelText: 'Late Score'),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  _scoringRules.lateScore = double.tryParse(value) ?? 0.75,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
