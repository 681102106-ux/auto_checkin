import 'package:auto_checkin/models/course.dart';
import 'package:auto_checkin/pages/create_course_screen.dart';
import 'package:auto_checkin/pages/course_detail_screen.dart';
import 'package:auto_checkin/services/firestore_service.dart'; // Import service
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService =
      FirestoreService(); // สร้าง instance ของ service

  void _showDeleteConfirmationDialog(Course course) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Course'),
          content: Text(
            'Are you sure you want to delete "${course.name}"? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                _firestoreService.deleteCourse(course.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${course.name}" has been deleted.')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not found.")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Professor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _auth.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<Course>>(
        stream: _firestoreService.getCoursesStream(
          user.uid,
        ), // ใช้ service ในการดึงข้อมูล
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No courses found.'));
          }
          final courses = snapshot.data!;
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(course.name),
                  subtitle: Text(course.professorName),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmationDialog(course),
                        tooltip: 'Delete Course',
                      ),
                    ],
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
