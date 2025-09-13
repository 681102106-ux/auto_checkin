import 'package:auto_checkin/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <<<--- Import เพิ่ม
import 'package:flutter/material.dart';
import '../models/course.dart';
import 'check_in_screen.dart';
import 'create_course_screen.dart';
import 'edit_course_screen.dart';
import '../services/course_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CourseService _courseService = CourseService();
  late List<Course> _courses;

  @override
  void initState() {
    super.initState();
    _courses = _courseService.getCourses();
  }

  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text('Are you sure you want to log out?')],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                // --- [จุดแก้ไขที่สำคัญที่สุด!] ---
                // 1. ปิด Pop-up ก่อน
                Navigator.of(context).pop();
                // 2. แจ้งให้ Firebase ทราบว่าเรา Logout แล้ว
                FirebaseAuth.instance.signOut();
                // 3. ไม่ต้องสั่งเปลี่ยนหน้าเอง! ปล่อยให้ AuthGate จัดการ
                // --- [จบการแก้ไข] ---
              },
            ),
          ],
        );
      },
    );
  }

  void _editCourse(Course courseToEdit) async {
    final updatedCourse = await Navigator.of(context).push<Course>(
      MaterialPageRoute(
        builder: (context) => EditCourseScreen(course: courseToEdit),
      ),
    );

    if (updatedCourse != null) {
      setState(() {
        _courseService.updateCourse(updatedCourse);
        _courses = _courseService.getCourses();
      });
    }
  }

  void _addCourse() async {
    final newCourse = await Navigator.of(context).push<Course>(
      MaterialPageRoute(builder: (context) => const CreateCourseScreen()),
    );

    if (newCourse != null) {
      setState(() {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutConfirmationDialog,
            tooltip: 'Logout',
          ),
        ],
      ),
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
