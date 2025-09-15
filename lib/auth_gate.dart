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
        // --- สถานะที่ 1: User ยังไม่ได้ Login ---
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [EmailAuthProvider()],
            headerBuilder: (context, constraints, shrinkOffset) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  // คุณสามารถใส่โลโก้หรือรูปภาพของแอปได้ที่นี่
                  child: Icon(Icons.school, size: 100, color: Colors.indigo),
                ),
              );
            },
          );
        }

        // --- สถานะที่ 2: User Login แล้ว, กำลังตรวจสอบ Role ---
        // เราจะใช้ FutureBuilder ที่แข็งแกร่งขึ้นในการจัดการ
        return RoleBasedScreen(user: snapshot.data!);
      },
    );
  }
}

// Widget ใหม่สำหรับจัดการการแสดงผลตาม Role โดยเฉพาะ
class RoleBasedScreen extends StatefulWidget {
  final User user;
  const RoleBasedScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<RoleBasedScreen> createState() => _RoleBasedScreenState();
}

class _RoleBasedScreenState extends State<RoleBasedScreen> {
  // สร้าง Future ขึ้นมาแค่ครั้งเดียวใน initState
  late Future<DocumentSnapshot> _userProfileFuture;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    // ให้ Future ทำงานแค่ครั้งเดียวตอนที่ Widget ถูกสร้างขึ้น
    // นี่คือการแก้ไขปัญหาอาการช้าและหน้าจอขาวที่สำคัญที่สุด!
    _userProfileFuture = _firestoreService
        .createUserProfileIfNeeded(widget.user)
        .then((_) => _firestoreService.getUserProfile(widget.user.uid));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _userProfileFuture,
      builder: (context, snapshot) {
        // --- สถานะที่ 2.1: กำลังโหลดข้อมูล Role ---
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Loading user profile..."),
                ],
              ),
            ),
          );
        }

        // --- สถานะที่ 2.2: เกิด Error ระหว่างโหลด ---
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Error loading profile: ${snapshot.error}\nPlease check your Firestore Rules and internet connection.",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        // --- สถานะที่ 2.3: โหลดสำเร็จ แต่ไม่เจอข้อมูล Role ---
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("User profile not found in database.")),
          );
        }

        // --- สถานะที่ 2.4: โหลดสำเร็จและเจอข้อมูล! ---
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final role = data['role'];

        if (role == 'professor') {
          return const HomeScreen(); // ไปหน้าอาจารย์
        } else {
          return const StudentScreen(); // ไปหน้านักเรียน (หรือ Role อื่นๆ)
        }
      },
    );
  }
}
