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
  bool _joinCodeEnabled = true;

  @override
  void dispose() {
    _courseNameController.dispose();
    _profNameController.dispose();
    super.dispose();
  }

  String _generateJoinCode() {
    const chars = 'ABCDEFGHIJKLMNPQRSTUVWXYZ123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  void _saveCourse() {
    // ใช้ validate() เพื่อตรวจสอบฟอร์มก่อน
    if (_formKey.currentState?.validate() ?? false) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final newCourse = Course(
        id: '',
        name: _courseNameController.text,
        professorName: _profNameController.text,
        scoringRules: _scoringRules,
        professorId: currentUser.uid,
        joinCode: _generateJoinCode(),
        joinCodeEnabled: _joinCodeEnabled,
      );

      CourseService().addCourse(newCourse).then((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Course')),
      // --- [จุดแก้ไขที่สำคัญที่สุด!] ---
      // เราจะใช้ Form หุ้ม ListView เพื่อให้ทั้งสองทำงานร่วมกันได้
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- Widget ทั้งหมดจะถูกวางเรียงกันในนี้ ---
            TextFormField(
              controller: _courseNameController,
              decoration: const InputDecoration(labelText: 'Course Name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a course name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _profNameController,
              decoration: const InputDecoration(labelText: 'Professor Name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a professor name';
                }
                return null;
              },
            ),
            const Divider(height: 32, thickness: 1),
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
            const Divider(height: 32, thickness: 1),
            Text(
              'Scoring Rules',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            _buildScoreEditor(
              'Present',
              _scoringRules.presentScore,
              (val) => _scoringRules.presentScore = val,
            ),
            _buildScoreEditor(
              'Absent',
              _scoringRules.absentScore,
              (val) => _scoringRules.absentScore = val,
            ),
            _buildScoreEditor(
              'On Leave',
              _scoringRules.onLeaveScore,
              (val) => _scoringRules.onLeaveScore = val,
            ),
            _buildScoreEditor(
              'Late',
              _scoringRules.lateScore,
              (val) => _scoringRules.lateScore = val,
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

  // --- ฟังก์ชันช่วยสร้าง UI แก้ไขคะแนนให้สะอาดขึ้น ---
  Widget _buildScoreEditor(
    String title,
    double initialValue,
    Function(double) onChanged,
  ) {
    return TextFormField(
      initialValue: initialValue.toString(),
      decoration: InputDecoration(labelText: '$title Score'),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (value) {
        onChanged(double.tryParse(value) ?? initialValue);
      },
    );
  }
}
