import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // <<<--- เราจะใช้ package ช่วยสร้าง ID ที่ไม่ซ้ำกัน
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

  // สร้าง State สำหรับเก็บค่าคะแนนในหน้านี้
  final _scoringRules = ScoringRules();

  @override
  void dispose() {
    _courseNameController.dispose();
    _profNameController.dispose();
    super.dispose();
  }

  void _saveCourse() {
    if (_formKey.currentState!.validate()) {
      // สร้าง Object ของ Course ใหม่
      final newCourse = Course(
        id: const Uuid().v4(), // สร้าง ID ที่ไม่ซ้ำกัน
        name: _courseNameController.text,
        professorName: _profNameController.text,
        scoringRules: _scoringRules, // ใช้กฎกติกาที่ตั้งค่าไว้
      );

      // ส่ง Course ที่สร้างใหม่กลับไปที่ HomeScreen
      Navigator.of(context).pop(newCourse);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Course'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- ส่วนของข้อมูลคลาส ---
            TextFormField(
              controller: _courseNameController,
              decoration: const InputDecoration(labelText: 'Course Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a course name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _profNameController,
              decoration: const InputDecoration(labelText: 'Professor Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a professor name';
                }
                return null;
              },
            ),
            const Divider(height: 32),
            // --- ส่วนของการตั้งค่าคะแนน ---
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

  // ฟังก์ชันช่วยสร้าง UI แก้ไขคะแนน
  Widget _buildScoreEditor(
    String title,
    double initialValue,
    Function(double) onChanged,
  ) {
    return TextFormField(
      initialValue: initialValue.toString(),
      decoration: InputDecoration(labelText: '$title Score'),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        onChanged(double.tryParse(value) ?? 0);
      },
    );
  }
}
