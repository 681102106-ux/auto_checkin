import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/scoring_rules.dart';
import 'check_in_screen.dart';
import 'create_course_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          final course = _courses[index];
          return ListTile(
            leading: const Icon(Icons.book, color: Colors.indigo),
            title: Text(course.name),
            subtitle: Text(course.professorName),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // **[จุดที่แก้ไข]** เราจะส่งแค่ "course" ทั้งก้อนไป
              // เพราะกฎกติกา (คะแนน) มันอยู่ใน course อยู่แล้ว
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
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
