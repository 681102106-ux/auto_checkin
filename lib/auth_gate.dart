import 'package:auto_checkin/pages/home_screen.dart';
import 'package:auto_checkin/pages/student_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// เปลี่ยน import จาก flutterfire_ui เป็น firebase_ui_auth
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // ใช้ SignInScreen จาก package ใหม่
          return SignInScreen(
            providerConfigs: const [EmailProviderConfiguration()],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  // ตรวจสอบให้แน่ใจว่า path ของรูปภาพถูกต้อง
                  child: Image.asset('assets/images/logo.png'),
                ),
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? const Text('Welcome to Auto Check-in, please sign in!')
                    : const Text('Welcome to Auto Check-in, please sign up!'),
              );
            },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
          );
        }

        // Logic การแยก Role ของ User (เหมือนเดิม)
        if (snapshot.data!.email!.contains('psu.ac.th')) {
          if (snapshot.data!.email!.contains(RegExp(r'[0-9]'))) {
            return const StudentScreen();
          } else {
            return const HomeScreen();
          }
        } else {
          return const StudentScreen();
        }
      },
    );
  }
}
