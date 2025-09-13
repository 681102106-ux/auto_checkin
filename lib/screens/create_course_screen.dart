import 'package:auto_checkin/services/course_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/course.dart';
import '../models/scoring_rules.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courseNameController = TextEditingController();
  final _profNameController = TextEditingController();
  final _scoringRules = ScoringRules();

  @override
  void dispose() {
    _courseNameController.dispose();
    _profNameController.dispose();
    super.dispose();
  }

  void _saveCourse() {
    if (_formKey.currentState!.validate()) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return; // ป้องกันถ้าไม่มี user

      final newCourse = Course(
        id: const Uuid().v4(), // id นี้ใช้แค่ในแอป ไม่ได้ใช้ใน firestore
        name: _courseNameController.text,
        professorName: _profNameController.text,
        scoringRules: _scoringRules,
        professorId: currentUser.uid, // <<<--- เพิ่ม ID ของอาจารย์
      );

      // เรียกใช้ Service เพื่อบันทึกข้อมูล
      CourseService().addCourse(newCourse).then((_) {
        Navigator.of(context).pop(); // กลับไปหน้า Home
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Course')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _courseNameController,
              decoration: const InputDecoration(labelText: 'Course Name'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a course name' : null,
            ),
            TextFormField(
              controller: _profNameController,
              decoration: const InputDecoration(labelText: 'Professor Name'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a professor name' : null,
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
              onPressed: _saveCourse,
              child: const Text('Save Course'),
            ),
          ],
        ),
      ),
    );
  }
}
