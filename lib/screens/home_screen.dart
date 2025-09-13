import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/course_service.dart';
import 'check_in_screen.dart';
import 'create_course_screen.dart';
import 'edit_course_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CourseService _courseService = CourseService();
  final currentUser = FirebaseAuth.instance.currentUser;

  // ไม่ต้องมี List<Course> _courses; ใน State อีกต่อไป!

  @override
  Widget build(BuildContext context) {
    // ป้องกันกรณีที่ไม่มี user (ไม่น่าจะเกิด แต่เผื่อไว้)
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("User not found.")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      // --- [เปลี่ยน] มาใช้ StreamBuilder ---
      body: StreamBuilder<List<Course>>(
        // "ฟัง" การเปลี่ยนแปลงของคลาสที่เป็นของอาจารย์คนนี้
        stream: _courseService.getCoursesStream(currentUser!.uid),
        builder: (context, snapshot) {
          // ถ้ากำลังโหลด...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // ถ้าเกิด Error...
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // ถ้าไม่มีข้อมูล...
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No courses found. Add one!'));
          }

          // ถ้ามีข้อมูล!
          final courses = snapshot.data!;
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return ListTile(
                title: Text(course.name),
                subtitle: Text(course.professorName),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CheckInScreen(course: course),
                    ),
                  );
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      onPressed: () {
                        // การแก้ไขยังทำงานเหมือนเดิม แต่จะไปเรียกใช้ service ตัวใหม่
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                EditCourseScreen(course: course),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        // ยืนยันก่อนลบ
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: Text(
                              'Are you sure you want to delete "${course.name}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _courseService.deleteCourse(course.id);
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // การสร้างคลาสยังทำงานเหมือนเดิม แต่จะไปเรียกใช้ service ตัวใหม่
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateCourseScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
