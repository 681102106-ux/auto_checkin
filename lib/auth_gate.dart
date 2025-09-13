import 'package:auto_checkin/screens/home_screen.dart';
import 'package:auto_checkin/screens/login_screen.dart';
import 'package:auto_checkin/screens/student_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ถ้า User ยังไม่ได้ล็อกอิน หรือกำลังรอการยืนยัน
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // ถ้า User ล็อกอินแล้ว
        // --- [ส่วนที่ปรับปรุง] ---
        // เราจะสร้าง Widget ที่รอการตรวจสอบ Role ในอนาคต
        // ตอนนี้เราจะยัง hardcode ให้ไปหน้า HomeScreen ก่อน
        // แต่โครงสร้างนี้พร้อมสำหรับการใส่ Logic จริงในเฟส 13 แล้ว
        return FutureBuilder(
          // TODO: ในเฟส 13 เราจะสร้างฟังก์ชัน getUserRole(snapshot.data!.uid)
          future: Future.value(
            true,
          ), // สมมติว่าตอนนี้ทุกคนเป็น Professor ไปก่อนเพื่อทดสอบ
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // TODO: ในเฟส 13 เราจะเช็ก `roleSnapshot.data` เพื่อแยกว่าจะไป HomeScreen หรือ StudentScreen
            // if (roleSnapshot.data == UserRole.professor) {
            //   return const HomeScreen();
            // } else {
            //   return const StudentScreen();
            // }

            return const HomeScreen(); // ตอนนี้ไปที่ HomeScreen ก่อน
          },
        );
        // --- [จบส่วนที่ปรับปรุง] ---
      },
    );
  }
}
