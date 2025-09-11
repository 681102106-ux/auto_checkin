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
  // 3. สร้าง "ข้อมูลจำลอง" (Mock Data) สำหรับรายวิชา
  // ในอนาคต เราจะไปดึงข้อมูลนี้มาจากฐานข้อมูลจริงๆ
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
    Course(id: 'CS305', name: 'Web Development', professorName: 'อ.สมชาย'),
    Course(id: 'MA101', name: 'Calculus I', professorName: 'อ.สมศรี'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // 7. เมื่อกดปุ่ม Settings ให้ "ส่งข้อมูลวิชา" ไปยังหน้า SettingsScreen
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      // 4. ใช้ ListView.builder เพื่อสร้างลิสต์ที่มีประสิทธิภาพ
      body: ListView.builder(
        itemCount: _courses.length, // บอก ListView ว่ามีกี่รายการ
        itemBuilder: (context, index) {
          final course = _courses[index];
          // 5. ใช้ ListTile ในการแสดงผลแต่ละรายการ
          return ListTile(
            leading: const Icon(Icons.book),
            title: Text(course.name),
            subtitle: Text(course.professorName),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // 6. เมื่อกดที่รายวิชา ให้ "ส่งข้อมูลวิชา" ไปยังหน้า CheckInScreen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CheckInScreen(course: course),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
