import 'package:auto_checkin/services/course_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';
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
  bool _joinCodeEnabled = true; // <<<--- [ใหม่!] State สำหรับสวิตช์

  // ... (dispose method และ _generateJoinCode เหมือนเดิม) ...
  @override
  void dispose() {
    _courseNameController.dispose();
    _profNameController.dispose();
    super.dispose();
  }

  String _generateJoinCode() {
    const chars =
        'ABCDEFGHIJKLMNPQRSTUVWXYZ123456789'; // เอา O กับ 0 ออกกันสับสน
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  void _saveCourse() {
    if (_formKey.currentState!.validate()) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final newCourse = Course(
        id: '',
        name: _courseNameController.text,
        professorName: _profNameController.text,
        scoringRules: _scoringRules,
        professorId: currentUser.uid,
        joinCode: _generateJoinCode(),
        joinCodeEnabled: _joinCodeEnabled, // <<<--- [ใหม่!] ใช้ค่าจาก State
      );

      CourseService().addCourse(newCourse).then((_) {
        Navigator.of(context).pop();
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
            // ... (TextFormField สำหรับชื่อคลาสและชื่ออาจารย์ เหมือนเดิม) ...
            const Divider(height: 32),

            // --- [ใหม่!] สวิตช์เปิด/ปิดรหัสเชิญ ---
            SwitchListTile(
              title: const Text('Enable Join Code'),
              subtitle: const Text(
                'Allow students to join this class using a code.',
              ),
              value: _joinCodeEnabled,
              onChanged: (bool value) {
                setState(() {
                  _joinCodeEnabled = value;
                });
              },
            ),
            const Divider(height: 32),

            // --- [จบส่วนใหม่] ---
            Text(
              'Scoring Rules',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            // ... (TextFormField สำหรับตั้งค่าคะแนน เหมือนเดิม) ...
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
