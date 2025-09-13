import 'package:auto_checkin/firebase_options.dart'; // <<<--- 1. Import ไฟล์ที่ถูกสร้างขึ้นมา
import 'package:auto_checkin/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // <<<--- 2. Import ปลั๊กของเรา

// 3. เปลี่ยน main ให้เป็น async และเพิ่มโค้ด Initialize
Future<void> main() async {
  // 4. ตรวจสอบให้แน่ใจว่า Widget ทั้งหมดพร้อมใช้งานก่อนเริ่มแอป
  WidgetsFlutterBinding.ensureInitialized();
  // 5. "เปิดสวิตช์" Firebase โดยใช้ข้อมูลจาก firebase_options.dart
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Check-in App', home: const AuthGate());
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoginScreen();
        }
        return const Scaffold(body: Center(child: Text('You are logged in!')));
      },
    );
  }
}
