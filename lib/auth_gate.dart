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
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [EmailAuthProvider()],
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                if (state.user?.metadata.creationTime ==
                    state.user?.metadata.lastSignInTime) {
                  // --- ส่วนที่แก้ไข: เรียกใช้ฟังก์ชันที่ถูกต้อง ---
                  FirestoreService().createUserProfileIfNeeded(state.user!);
                }
              }),
            ],
          );
        }
        return RoleBasedScreen(user: snapshot.data!);
      },
    );
  }
}

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
    // --- ส่วนที่แก้ไข: เรียกใช้ฟังก์ชันที่ถูกต้อง ---
    _userProfileFuture = _firestoreService.getUserProfile(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _userProfileFuture,
      builder: (context, snapshot) {
        // ... (UI เดิมถูกต้องอยู่แล้ว) ...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("Could not load profile.")),
          );
        }
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final role = data['role'];
        return role == 'professor' ? const HomeScreen() : const StudentScreen();
      },
    );
  }
}
