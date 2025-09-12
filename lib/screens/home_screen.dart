import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/scoring_rules.dart';
import 'check_in_screen.dart';
import 'create_course_screen.dart';
import 'edit_course_screen.dart'; // <<<--- Import หน้า Edit เข้ามา

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Course> _courses = [
    Course(
      id: 'CS101',
      name: 'Introduction to Computer Science',
      professorName: 'อ.นราศักดิ์',
      scoringRules: ScoringRules(),
    ),
    Course(
      id: 'MA101',
      name: 'Calculus I',
      professorName: 'อ.สมศรี',
      scoringRules: ScoringRules(presentScore: 2.0, lateScore: 1.0),
    ),
  ];

  // --- [ฟังก์ชันใหม่] สำหรับเปิดหน้า Edit และรับข้อมูลกลับมา ---
  void _editCourse(Course courseToEdit) async {
    final updatedCourse = await Navigator.of(context).push<Course>(
      MaterialPageRoute(
        builder: (context) => EditCourseScreen(course: courseToEdit),
      ),
    );

    if (updatedCourse != null) {
      setState(() {
        // หา index ของคลาสเก่า แล้วแทนที่ด้วยคลาสที่อัปเดตแล้ว
        final index = _courses.indexWhere((c) => c.id == updatedCourse.id);
        if (index != -1) {
          _courses[index] = updatedCourse;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Courses')),
      body: ListView.builder(
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          final course = _courses[index];
          return ListTile(
            leading: const Icon(Icons.book, color: Colors.indigo),
            title: Text(course.name),
            subtitle: Text(course.professorName),
            // --- [แก้ไข] เพิ่มปุ่ม Edit ที่ท้ายรายการ ---
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: Colors.grey),
              onPressed: () => _editCourse(course),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CheckInScreen(course: course),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newCourse = await Navigator.of(context).push<Course>(
            MaterialPageRoute(builder: (context) => const CreateCourseScreen()),
          );

          if (newCourse != null) {
            setState(() {
              _courses.add(newCourse);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
