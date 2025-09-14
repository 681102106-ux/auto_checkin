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
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authSnapshot.hasData) {
          return const LoginScreen();
        }

        final user = authSnapshot.data!;
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirestoreService().userDocumentStream(user.uid),
          builder: (context, userDocSnapshot) {
            if (userDocSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // กรณีที่เพิ่งสมัครและยังไม่มีข้อมูลใน Firestore
            if (!userDocSnapshot.hasData || !userDocSnapshot.data!.exists) {
              return const CreateProfileScreen();
            }

            final userData = userDocSnapshot.data!.data();
            final isProfileComplete = userData?['profileComplete'] ?? false;

            if (!isProfileComplete) {
              return const CreateProfileScreen();
            }

            final roleString = userData?['role'] ?? 'student';
            final role = roleString == 'professor'
                ? UserRole.professor
                : UserRole.student;

            if (role == UserRole.professor) {
              return const HomeScreen();
            } else {
              return const StudentScreen();
            }
          },
        );
      },
    );
  }
}
