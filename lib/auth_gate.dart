import 'package:auto_checkin/screens/login_screen.dart';
import 'package:auto_checkin/screens/student_screen.dart'; // <<<--- หมายเหตุ*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // ฟังการเปลี่ยนแปลงสถานะการล็อกอินจาก Firebase
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ถ้ายังไม่มีข้อมูล (กำลังเช็ก) ให้แสดงหน้าจอโหลด
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // ถ้ามีข้อมูล (ล็อกอินแล้ว) ให้ไปที่หน้าแอปหลัก
        // *หมายเหตุ: ตอนนี้เราจะให้ทุกคนไปที่หน้า Student ก่อน
        // ในเฟสต่อไป เราจะทำให้มันฉลาดขึ้นและแยก Role ได้
        return const StudentScreen();
      },
    );
  }
}
