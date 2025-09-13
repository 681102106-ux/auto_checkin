import 'package:auto_checkin/screens/home_screen.dart';
import 'package:auto_checkin/screens/login_screen.dart';
import 'package:auto_checkin/screens/student_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <<<--- แก้ไขที่อยู่ตรงนี้ให้ถูกต้อง
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // TODO: In the future, we will check user roles here.
        // For now, we assume every logged-in user is a student.
        return const HomeScreen();
      },
    );
  }
}
