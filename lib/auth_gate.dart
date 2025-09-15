import 'package:auto_checkin/pages/home_screen.dart';
import 'package:auto_checkin/pages/student_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ตรวจสอบให้แน่ใจว่า import path นี้ถูกต้อง
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providerConfigs: const [EmailProviderConfiguration()],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
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
