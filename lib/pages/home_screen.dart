import 'package:auto_checkin/models/course.dart';
import 'package:auto_checkin/pages/create_course_screen.dart';
import 'package:auto_checkin/pages/course_detail_screen.dart';
import 'package:auto_checkin/pages/professor_students_screen.dart';
import 'package:auto_checkin/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  void _showDeleteConfirmationDialog(BuildContext context, Course course) {
    // 1. "จดที่อยู่" ของ ScaffoldMessenger ไว้ในตัวแปรนี้ก่อน
    //    เพื่อให้เราสามารถเรียกใช้ได้ แม้ว่า Context ของ Dialog จะหายไปแล้ว
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete "${course.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              // ปิด Dialog ทันทีที่กด
              Navigator.of(ctx).pop();
              try {
                // รอให้การลบข้อมูลเสร็จสิ้น
                await _firestoreService.deleteCourse(course.id);

                // --- นี่คือส่วนที่แก้ไขครับ ---
                // เราจะใช้ `scaffoldMessenger` ที่เรา "จดที่อยู่" ไว้ก่อนหน้า
                // เพื่อแสดง SnackBar อย่างปลอดภัย 100%
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('"${course.name}" has been deleted.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              } catch (e) {
                // --- นี่คือส่วนที่แก้ไขครับ ---
                // เช่นเดียวกัน เราจะใช้ `scaffoldMessenger` ตัวเดิม
                // เพื่อแสดง Error อย่างปลอดภัย
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete course: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Authenticating...")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Professor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfessorStudentsScreen(),
                ),
              );
            },
            tooltip: 'All My Students',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _auth.signOut(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: StreamBuilder<List<Course>>(
        stream: _firestoreService.getCoursesStreamForProfessor(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No courses found.\nTap the "+" button to create one!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final courses = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      course.name.isNotEmpty
                          ? course.name.substring(0, 1)
                          : '?',
                    ),
                    backgroundColor: Colors.indigo.shade100,
                  ),
                  title: Text(
                    course.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(course.professorName),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () =>
                        _showDeleteConfirmationDialog(context, course),
                    tooltip: 'Delete Course',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CourseDetailScreen(course: course),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateCourseScreen()),
          );
        },
        tooltip: 'Create New Course',
        child: const Icon(Icons.add),
      ),
    );
  }
}
