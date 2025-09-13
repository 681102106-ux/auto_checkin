import 'package:flutter/material.dart';
import '../models/course.dart';

class EditCourseScreen extends StatefulWidget {
  // รับคลาสที่ต้องการแก้ไขเข้ามา
  final Course course;

  const EditCourseScreen({super.key, required this.course});

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  final _formKey = GlobalKey<FormState>();

  // สร้าง Controller และกำหนดค่าเริ่มต้นจากข้อมูลเก่า
  late TextEditingController _courseNameController;
  late TextEditingController _profNameController;
  late TextEditingController _presentScoreController;
  late TextEditingController _absentScoreController;
  late TextEditingController _onLeaveScoreController;
  late TextEditingController _lateScoreController;

  @override
  void initState() {
    super.initState();
    // นำข้อมูลของ course ที่รับเข้ามา มาใส่ใน Controller
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
  }

  @override
  void dispose() {
    // อย่าลืม dispose controller ทั้งหมด
    _courseNameController.dispose();
    _profNameController.dispose();
    _presentScoreController.dispose();
    _absentScoreController.dispose();
    _onLeaveScoreController.dispose();
    _lateScoreController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedCourse = Course(
        id: widget.course.id, // ใช้ ID เดิม
        name: _courseName,
        professorName: _professorName,
        professorId: widget.course.professorId, // ใช้ professorId เดิม
        scoringRules: _scoringRules,
      );

      // เรียกใช้ Service ตัวใหม่
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
