import 'package:flutter/material.dart';
import '../models/course.dart';
import 'check_in_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- [โค้ดใหม่] ย้าย "ขุมทรัพย์" (ค่าคะแนน) มาไว้ที่นี่! ---
  Map<String, double> _scores = {
    'present': 1.0,
    'absent': 0.0,
    'onLeave': 0.5,
    'late': 0.75,
  };

  // --- [โค้ดใหม่] สร้างฟังก์ชันสำหรับให้หน้า Settings เรียกใช้เพื่ออัปเดตคะแนน ---
  void _updateScores(Map<String, double> newScores) {
    setState(() {
      _scores = newScores;
    });
  }

  // ... (ข้อมูลจำลองของรายวิชาเหมือนเดิม)
  final List<Course> _courses = [
    Course(
      id: 'CS101',
      name: 'Introduction to Computer Science',
      professorName: 'อ.นราศักดิ์',
    ),
    Course(
      id: 'CS203',
      name: 'Data Structures and Algorithms',
      professorName: 'อ.นราศักดิ์',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // --- [แก้ไข] ส่ง "ค่าคะแนน" และ "ฟังก์ชันอัปเดต" ไปให้หน้า Settings ---
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    initialScores: _scores,
                    onScoresUpdated: _updateScores,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          final course = _courses[index];
          return ListTile(
            title: Text(course.name),
            subtitle: Text(course.professorName),
            onTap: () {
              // --- [แก้ไข] ส่ง "ค่าคะแนน" ไปให้หน้า CheckInScreen ด้วย! ---
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      CheckInScreen(course: course, scores: _scores),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
