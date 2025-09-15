import 'package:auto_checkin/services/course_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/course.dart';
import 'check_in_screen.dart';
import 'create_course_screen.dart';
import 'edit_course_screen.dart';
import 'manage_roster_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CourseService _courseService = CourseService();
  final currentUser = FirebaseAuth.instance.currentUser;

  void _editCourse(Course courseToEdit) async {
    await Navigator.of(context).push<Course>(
      MaterialPageRoute(
        builder: (context) => EditCourseScreen(course: courseToEdit),
      ),
    );
  }

  void _addCourse() {
    Navigator.of(context).push<Course>(
      MaterialPageRoute(builder: (context) => const CreateCourseScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("Error: User not logged in.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Course>>(
        stream: _courseService.getCoursesStream(currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No courses found. Tap "+" to add one!'),
            );
          }

          final courses = snapshot.data!;
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return ListTile(
                leading: const Icon(Icons.book, color: Colors.indigo),
                title: Text(course.name),
                subtitle: Text(course.professorName),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.people, color: Colors.blueAccent),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ManageRosterScreen(course: course),
                          ),
                        );
                      },
                      tooltip: 'Manage Roster',
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      onPressed: () => _editCourse(course),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: Text(
                              'Are you sure you want to delete "${course.name}"? This cannot be undone.',
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
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CheckInScreen(course: course),
                    ),
                  );
                },
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
