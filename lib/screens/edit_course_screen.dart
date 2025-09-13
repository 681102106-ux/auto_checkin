import 'package:auto_checkin/services/course_service.dart'; // <<<--- 1. Import พ่อครัวเข้ามา
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

  // --- 2. สร้าง Controller สำหรับทุกช่องกรอก ---
  late TextEditingController _courseNameController;
  late TextEditingController _profNameController;
  // เราจะใช้ ScoringRules object โดยตรง ไม่ต้องมี controller แยก
  late ScoringRules _scoringRules;

  @override
  void initState() {
    super.initState();
    // 3. กำหนดค่าเริ่มต้นให้ Controller จากข้อมูลคลาสที่รับเข้ามา
    _courseNameController = TextEditingController(text: widget.course.name);
    _profNameController = TextEditingController(
      text: widget.course.professorName,
    );
    // สร้างสำเนาของ scoring rules เพื่อให้แก้ไขได้โดยไม่กระทบของเดิมทันที
    _scoringRules = ScoringRules.fromJson(widget.course.scoringRules.toJson());
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _profNameController.dispose();
    super.dispose();
  }

  // --- 4. สร้างฟังก์ชัน _saveChanges ขึ้นมา ---
  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedCourse = Course(
        id: widget.course.id, // ใช้ ID เดิม
        name: _courseNameController.text, // อ่านค่าจาก Controller
        professorName: _profNameController.text, // อ่านค่าจาก Controller
        professorId: widget.course.professorId, // ใช้ professorId เดิม
        scoringRules: _scoringRules, // ใช้ scoring rules ที่อัปเดตแล้ว
      );

      CourseService().updateCourse(updatedCourse).then((_) {
        Navigator.of(context).pop(); // กลับไปหน้า Home
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
              onPressed: _saveChanges, // <<<--- 5. เรียกใช้ฟังก์ชันที่ถูกต้อง
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
