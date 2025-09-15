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

  // --- [แก้ไข!] ใช้ Controller สำหรับทุกฟิลด์ ---
  late TextEditingController _courseNameController;
  late TextEditingController _profNameController;
  late TextEditingController _presentScoreController;
  late TextEditingController _absentScoreController;
  late TextEditingController _onLeaveScoreController;
  late TextEditingController _lateScoreController;
  late bool _joinCodeEnabled;

  @override
  void initState() {
    super.initState();
    _courseNameController = TextEditingController(text: widget.course.name);
    _profNameController = TextEditingController(
      text: widget.course.professorName,
    );
    _presentScoreController = TextEditingController(
      text: widget.course.scoringRules.presentScore.toString(),
    );
    _absentScoreController = TextEditingController(
      text: widget.course.scoringRules.absentScore.toString(),
    );
    _onLeaveScoreController = TextEditingController(
      text: widget.course.scoringRules.onLeaveScore.toString(),
    );
    _lateScoreController = TextEditingController(
      text: widget.course.scoringRules.lateScore.toString(),
    );
    _joinCodeEnabled = widget.course.joinCodeEnabled;
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _profNameController.dispose();
    _presentScoreController.dispose();
    _absentScoreController.dispose();
    _onLeaveScoreController.dispose();
    _lateScoreController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedCourse = Course(
        id: widget.course.id,
        name: _courseNameController.text,
        professorName: _profNameController.text,
        professorId: widget.course.professorId,
        scoringRules: ScoringRules(
          presentScore: double.tryParse(_presentScoreController.text) ?? 1.0,
          absentScore: double.tryParse(_absentScoreController.text) ?? 0.0,
          onLeaveScore: double.tryParse(_onLeaveScoreController.text) ?? 0.5,
          lateScore: double.tryParse(_lateScoreController.text) ?? 0.75,
        ),
        joinCode: widget.course.joinCode,
        joinCodeEnabled: _joinCodeEnabled,
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
            ),
            TextFormField(
              controller: _profNameController,
              decoration: const InputDecoration(labelText: 'Professor Name'),
            ),
            const Divider(height: 32),
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
              controller: _presentScoreController,
              decoration: const InputDecoration(labelText: 'Present Score'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _absentScoreController,
              decoration: const InputDecoration(labelText: 'Absent Score'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _onLeaveScoreController,
              decoration: const InputDecoration(labelText: 'On Leave Score'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _lateScoreController,
              decoration: const InputDecoration(labelText: 'Late Score'),
              keyboardType: TextInputType.number,
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
