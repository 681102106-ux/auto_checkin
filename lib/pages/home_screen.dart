import 'package:auto_checkin/models/course.dart';
import 'package:auto_checkin/pages/create_course_screen.dart';
import 'package:auto_checkin/pages/course_detail_screen.dart';
import 'package:auto_checkin/pages/professor_students_screen.dart';
import 'package:auto_checkin/services/firestore_service.dart'; // 1. Import ที่ถูกต้อง
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // 2. เรียกใช้ "สุดยอดเชฟ" คนใหม่
  final FirestoreService _firestoreService = FirestoreService();

  // ฟังก์ชันสำหรับแสดง Dialog ยืนยันการลบ
  void _showDeleteConfirmationDialog(BuildContext context, Course course) {
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
            onPressed: () {
              _firestoreService.deleteCourse(course.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${course.name}" has been deleted.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
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
      // Should not happen if AuthGate is working, but acts as a safeguard.
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
        // 3. แก้ไขการเรียกใช้ฟังก์ชันให้ถูกต้อง
        stream: _firestoreService.getCoursesStreamForProfessor(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
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
