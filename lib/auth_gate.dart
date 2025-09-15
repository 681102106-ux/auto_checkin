import 'package:auto_checkin/pages/home_screen.dart';
import 'package:auto_checkin/pages/student_screen.dart';
import 'package:auto_checkin/services/firestore_service.dart';
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
        // User ยังไม่ได้ Login
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [EmailAuthProvider()],
            // --- แก้ไขตามสpeg: เพิ่ม actions ---
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                // ตรวจสอบว่าเป็น User ที่เพิ่งสมัครใหม่หรือไม่
                if (state.user?.metadata.creationTime ==
                    state.user?.metadata.lastSignInTime) {
                  print("New user detected! Creating profile...");
                  FirestoreService().createUserProfileIfNeeded(state.user!);
                }
              }),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Icon(Icons.school, size: 100, color: Colors.indigo),
              );
            },
          );
        }
        // User Login แล้ว, ไปยังหน้าตรวจสอบ Role
        return RoleBasedScreen(user: snapshot.data!);
      },
    );
  }
}

// Widget สำหรับตรวจสอบ Role อย่างเสถียร
class RoleBasedScreen extends StatefulWidget {
  final User user;
  const RoleBasedScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<RoleBasedScreen> createState() => _RoleBasedScreenState();
}

class _RoleBasedScreenState extends State<RoleBasedScreen> {
  late Future<DocumentSnapshot> _userProfileFuture;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    // สร้าง Future แค่ครั้งเดียวเพื่อประสิทธิภาพสูงสุด
    _userProfileFuture = _firestoreService.getUserProfile(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _userProfileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("User profile not found.")),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final role = data['role'];

        if (role == 'professor') {
          return const HomeScreen();
        } else {
          return const StudentScreen();
        }
      },
    );
  }
}
