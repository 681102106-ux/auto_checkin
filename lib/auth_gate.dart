import 'package:auto_checkin/pages/home_screen.dart';
import 'package:auto_checkin/pages/student_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // ลบ const ออกจาก SignInScreen
          return SignInScreen(
            providerConfigs: const [EmailProviderConfiguration()],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  // แก้ไข path รูปภาพให้ถูกต้อง
                  child: Image.asset('assets/logo.png'),
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
        if (snapshot.data!.email!.contains('psu.ac.th')) {
          if (snapshot.data!.email!.contains(RegExp(r'[0-9]'))) {
            return const StudentScreen();
          } else {
            // ลบ const ออกจาก HomeScreen
            return const HomeScreen();
          }
        } else {
          return const StudentScreen();
        }
      },
    );
  }
}
