import 'package:auto_checkin/pages/home_screen.dart';
import 'package:auto_checkin/pages/student_screen.dart';
import 'package:auto_checkin/services/firestore_service.dart'; // Import service
import 'package:cloud_firestore/cloud_firestore.dart';
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
        // ถ้ายังไม่มี User login อยู่
        if (!snapshot.hasData) {
          return SignInScreen(providers: [EmailAuthProvider()]);
        }

        // --- Logic ใหม่: เมื่อ User login แล้ว ---
        final user = snapshot.data!;
        final firestoreService = FirestoreService();

        // เราจะใช้ FutureBuilder เพื่อรอผลการตรวจสอบและดึง Role
        return FutureBuilder<DocumentSnapshot>(
          // 1. สร้างโปรไฟล์ (ถ้ายังไม่มี) และดึงข้อมูลกลับมา
          future: firestoreService.createUserProfileIfNeeded(user).then((_) {
            return firestoreService.getUserProfile(user.uid);
          }),
          builder: (context, userProfileSnapshot) {
            // ขณะกำลังโหลดข้อมูล...
            if (userProfileSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // ถ้าหาโปรไฟล์ไม่เจอ หรือมี Error
            if (!userProfileSnapshot.hasData ||
                !userProfileSnapshot.data!.exists) {
              return const Scaffold(
                body: Center(child: Text('Could not load user profile.')),
              );
            }

            // 2. อ่าน Role จากข้อมูลที่ได้มา
            final data =
                userProfileSnapshot.data!.data() as Map<String, dynamic>;
            final role = data['role'];

            // 3. แยกเส้นทางตาม Role
            if (role == 'professor') {
              return const HomeScreen(); // ไปหน้าอาจารย์
            } else {
              return const StudentScreen(); // ไปหน้านักเรียน
            }
          },
        );
      },
    );
  }
}
