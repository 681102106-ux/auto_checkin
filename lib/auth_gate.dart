import 'package:auto_checkin/pages/home_screen.dart';
import 'package:auto_checkin/pages/student_screen.dart';
import 'package:auto_checkin/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- นี่คือบรรทัดที่แก้ไขครับ ---
// เราจะซ่อนคลาสที่ชื่อซ้ำกันจาก package นี้ไป
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // ตอนนี้ Dart จะไม่สับสนแล้วว่า EmailAuthProvider() มาจากไหน
          return SignInScreen(providers: [EmailAuthProvider()]);
        }

        final user = snapshot.data!;
        final firestoreService = FirestoreService();

        return FutureBuilder<DocumentSnapshot>(
          future: firestoreService.createUserProfileIfNeeded(user).then((_) {
            return firestoreService.getUserProfile(user.uid);
          }),
          builder: (context, userProfileSnapshot) {
            if (userProfileSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // --- นี่คือส่วนที่อัปเกรดครับ ---
            // เพิ่มการดักจับ Error เพื่อให้เรารู้ว่าเกิดอะไรขึ้น
            if (userProfileSnapshot.hasError) {
              // สำหรับนักพัฒนา: แสดง error ใน console เพื่อให้แก้บัคง่ายขึ้น
              print("Error loading user profile: ${userProfileSnapshot.error}");
              return Scaffold(
                body: Center(
                  child: Text(
                    "An error occurred: ${userProfileSnapshot.error}",
                  ),
                ),
              );
            }

            if (!userProfileSnapshot.hasData ||
                !userProfileSnapshot.data!.exists) {
              return const Scaffold(
                body: Center(
                  child: Text('Could not load user profile. Please try again.'),
                ),
              );
            }

            final data =
                userProfileSnapshot.data!.data() as Map<String, dynamic>;
            final role = data['role'];

            if (role == 'professor') {
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
