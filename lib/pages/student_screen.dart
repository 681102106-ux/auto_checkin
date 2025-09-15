import 'package:auto_checkin/models/course.dart';
import 'package:auto_checkin/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({Key? key}) : super(key: key);

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    // หาก user เป็น null ให้แสดงหน้าจอว่างๆ ป้องกัน error
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not logged in.")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วนหัวต้อนรับ
            Text(
              'Welcome, ${user.displayName ?? user.email}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),

            // หมายเหตุ: สามารถวางปุ่ม Action ต่างๆ (เช่น Join Class) ไว้ตรงนี้ได้
            const Divider(),
            const SizedBox(height: 10),

            // ส่วนหัวของ "ชั้นหนังสือ"
            Text(
              "My Enrolled Courses",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),

            // "ชั้นหนังสือ" ที่ดึงข้อมูลแบบ Real-time
            Expanded(
              child: StreamBuilder<List<Course>>(
                stream: _firestoreService.getEnrolledCoursesStream(user.uid),
                builder: (context, snapshot) {
                  // สถานะ: กำลังโหลด
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // สถานะ: มี Error
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  // สถานะ: ไม่มีข้อมูล (ยังไม่เคยลงทะเบียน)
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "You haven't enrolled in any courses yet.\nJoin a class by scanning a QR code.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  // สถานะ: มีข้อมูล แสดงผลรายชื่อวิชา
                  final courses = snapshot.data!;

                  return ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            child: const Icon(Icons.class_outlined),
                          ),
                          title: Text(
                            course.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(course.professorName),
                          // สามารถเพิ่ม onTap เพื่อไปยังหน้ารายละเอียดของคลาสได้ในอนาคต
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
