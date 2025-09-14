import 'package:auto_checkin/screens/create_profile_screen.dart';
import 'package:auto_checkin/screens/home_screen.dart';
import 'package:auto_checkin/screens/login_screen.dart';
import 'package:auto_checkin/screens/student_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'models/user_role.dart';
import 'services/firestore_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // --- ส่วนที่ 1: เช็กว่าล็อกอินหรือยัง ---
        if (!authSnapshot.hasData) {
          // ยังไม่ได้ล็อกอิน -> ไปหน้า Login
          return const LoginScreen();
        }

        // --- ส่วนที่ 2: ถ้าล็อกอินแล้ว มาเช็กโปรไฟล์กัน ---
        final user = authSnapshot.data!;
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          // เรียก "พ่อครัวใหญ่" ให้ "เงี่ยหูฟัง" การเปลี่ยนแปลงของข้อมูล User
          stream: FirestoreService().userDocumentStream(user.uid),
          builder: (context, userDocSnapshot) {
            // ถ้ากำลังโหลดข้อมูล...
            if (userDocSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // ถ้าไม่มีข้อมูล User ใน Firestore เลย (อาจจะเพิ่งสมัคร)
            if (!userDocSnapshot.hasData || !userDocSnapshot.data!.exists) {
              return const CreateProfileScreen();
            }

            final userData = userDocSnapshot.data!.data();
            final isProfileComplete = userData?['profileComplete'] ?? false;
            final roleString = userData?['role'] ?? 'student';
            final role = roleString == 'professor'
                ? UserRole.professor
                : UserRole.student;

            // ถ้าโปรไฟล์ "ยังไม่สมบูรณ์" -> บังคับไปหน้าสร้างโปรไฟล์
            if (!isProfileComplete) {
              return const CreateProfileScreen();
            }

            // --- ส่วนที่ 3: ถ้าโปรไฟล์สมบูรณ์แล้ว ค่อยมาเช็ก Role ---
            if (role == UserRole.professor) {
              return const HomeScreen(); // ถ้าเป็นอาจารย์ -> ไปหน้า Home
            } else {
              return const StudentScreen(); // ถ้าเป็นนักเรียน -> ไปหน้า Student
            }
          },
        );
      },
    );
  }
}
