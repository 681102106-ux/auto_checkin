import 'package:flutter/material.dart';
import '../models/course.dart';
import 'check_in_screen.dart';
import 'create_course_screen.dart';
import 'edit_course_screen.dart';
import '../services/course_service.dart'; // <<<--- 1. Import พ่อครัวเข้ามา

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 2. สร้าง "พ่อครัว" ขึ้นมา 1 คน
  final CourseService _courseService = CourseService();

  // 3. สร้าง "ถาดเสิร์ฟ" (State) เพื่อรอรับอาหารจากพ่อครัว
  late List<Course> _courses;

  @override
  void initState() {
    super.initState();
    // 4. สั่งให้พ่อครัว "เตรียมอาหาร" (ดึงข้อมูล) ตั้งแต่แรก
    _courses = _courseService.getCourses();
  }

  // ฟังก์ชันสำหรับเปิดหน้า Edit และรับข้อมูลกลับมา
  void _editCourse(Course courseToEdit) async {
    final updatedCourse = await Navigator.of(context).push<Course>(
      MaterialPageRoute(
        builder: (context) => EditCourseScreen(course: courseToEdit),
      ),
    );

    if (updatedCourse != null) {
      setState(() {
        // 5. บอกให้พ่อครัว "อัปเดตเมนู"
        _courseService.updateCourse(updatedCourse);
        // แล้วเราก็ขอเมนูที่อัปเดตแล้วมาใส่ถาดเสิร์ฟใหม่
        _courses = _courseService.getCourses();
      });
    }
  }

  // ฟังก์ชันสำหรับเปิดหน้า Create และรับข้อมูลกลับมา
  void _addCourse() async {
    final newCourse = await Navigator.of(context).push<Course>(
      MaterialPageRoute(builder: (context) => const CreateCourseScreen()),
    );

    if (newCourse != null) {
      setState(() {
        // 6. บอกให้พ่อครัว "เพิ่มเมนูใหม่"
        _courseService.addCourse(newCourse);
        _courses = _courseService.getCourses();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      // UI ที่เหลือเหมือนเดิมเป๊ะ! พนักงานเสิร์ฟไม่ต้องเปลี่ยนวิธีทำงานเลย!
      body: ListView.builder(
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          final course = _courses[index];
          return ListTile(
            leading: const Icon(Icons.book, color: Colors.indigo),
            title: Text(course.name),
            subtitle: Text(course.professorName),
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
        onPressed: _addCourse,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
