import 'package:auto_checkin/screens/create_profile_screen.dart';
import 'package:auto_checkin/screens/home_screen.dart';
import 'package:auto_checkin/screens/login_screen.dart';
import 'package:auto_checkin/screens/student_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <<<--- Import เพิ่ม
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
        if (!authSnapshot.hasData) {
          return const LoginScreen();
        }

        final user = authSnapshot.data!;
        // --- [แก้ไข] เปลี่ยนจาก FutureBuilder เป็น StreamBuilder ---
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          // "เงี่ยหูฟัง" การเปลี่ยนแปลงของข้อมูล User คนนี้
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
              // ให้ไปหน้าสร้างโปรไฟล์ (ซึ่งเป็นกรณีที่ไม่น่าจะเกิด แต่ป้องกันไว้ก่อน)
              return const CreateProfileScreen();
            }

            // ดึงข้อมูลจาก Snapshot
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

            // ถ้าโปรไฟล์สมบูรณ์แล้ว -> แยก Role
            if (role == UserRole.professor) {
              return const HomeScreen();
            } else {
              return const StudentScreen();
            }
          },
        );
        // --- [จบการแก้ไข] ---
      },
    );
  }
}
