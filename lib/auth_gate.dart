import 'package:auto_checkin/screens/create_profile_screen.dart';
import 'package:auto_checkin/screens/home_screen.dart';
import 'package:auto_checkin/screens/login_screen.dart';
import 'package:auto_checkin/screens/student_screen.dart';
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
      builder: (context, snapshot) {
        // --- ส่วนที่ 1: เช็กว่าล็อกอินหรือยัง ---
        if (!snapshot.hasData) {
          // ยังไม่ได้ล็อกอิน -> ไปหน้า Login
          return const LoginScreen();
        }

        // --- ส่วนที่ 2: ถ้าล็อกอินแล้ว มาเช็กโปรไฟล์กัน ---
        final user = snapshot.data!;
        return FutureBuilder<bool>(
          // เรียก "พ่อครัวใหญ่" ให้ไปเช็กว่าโปรไฟล์สมบูรณ์ไหม
          future: FirestoreService().isUserProfileComplete(user.uid),
          builder: (context, profileSnapshot) {
            // ถ้ากำลังโหลดข้อมูลโปรไฟล์...
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // ถ้าโปรไฟล์ "ยังไม่สมบูรณ์" -> บังคับไปหน้าสร้างโปรไฟล์
            if (profileSnapshot.data == false) {
              return const CreateProfileScreen();
            }

            // --- ส่วนที่ 3: ถ้าโปรไฟล์สมบูรณ์แล้ว ค่อยมาเช็ก Role ---
            return FutureBuilder<UserRole>(
              future: FirestoreService().getUserRole(user.uid),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (roleSnapshot.data == UserRole.professor) {
                  return const HomeScreen(); // ถ้าเป็นอาจารย์ -> ไปหน้า Home
                } else {
                  return const StudentScreen(); // ถ้าเป็นนักเรียน -> ไปหน้า Student
                }
              },
            );
          },
        );
      },
    );
  }
}
