// --- นี่คือส่วนที่แก้ไขครับ ---
// เปลี่ยนจาก "ที่อยู่เต็ม" มาเป็น "เส้นทางลัด" ที่แม่นยำกว่า
import 'pages/home_screen.dart';
import 'pages/student_screen.dart';
import 'services/firestore_service.dart';
// ----------------------------

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
        // --- ส่วนที่ 1: User ยังไม่ได้ Login ---
        if (!snapshot.hasData) {
          return Scaffold(
            body: Stack(
              children: [
                // Layer 1: พื้นหลังไล่สี
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.indigo.shade300, Colors.blue.shade500],
                    ),
                  ),
                ),
                // Layer 2: ฟอร์ม Login ที่ลอยอยู่ตรงกลาง
                Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                          ),
                          child: SignInScreen(
                            providers: [EmailAuthProvider()],
                            actions: [
                              AuthStateChangeAction<SignedIn>((context, state) {
                                if (state.user?.metadata.creationTime ==
                                    state.user?.metadata.lastSignInTime) {
                                  FirestoreService().createUserProfileIfNeeded(
                                    state.user!,
                                  );
                                }
                              }),
                            ],
                            headerBuilder: (context, constraints, shrinkOffset) {
                              return Column(
                                children: [
                                  const Icon(
                                    Icons.school_outlined,
                                    size: 80,
                                    // --- นี่คือส่วนที่แก้ไขครับ ---
                                    // เราจะระบุสีที่แน่นอน (Colors.indigo) ลงไปเลย
                                    // เพื่อป้องกันไม่ให้ SignInScreen สับสน
                                    color: Colors.indigo,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Auto Check-in',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Welcome! Please sign in to continue.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              );
                            },
                            styles: const {
                              EmailFormStyle(
                                signInButtonVariant: ButtonVariant.filled,
                              ),
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // --- ส่วนที่ 2: User Login แล้ว, ไปยังหน้าตรวจสอบ Role ---
        return RoleBasedScreen(user: snapshot.data!);
      },
    );
  }
}

// ... (Widget RoleBasedScreen เหมือนเดิม ไม่มีการเปลี่ยนแปลง) ...
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
