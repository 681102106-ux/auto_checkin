import 'package:auto_checkin/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // ทำให้แน่ใจว่าทุกอย่างพร้อมก่อนเริ่มแอป
  WidgetsFlutterBinding.ensureInitialized();
  // รอให้ Firebase เริ่มทำงานให้เสร็จสมบูรณ์
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Check-in',
      theme: ThemeData(
        primarySwatch: Colors.indigo, // ลองเปลี่ยนสีธีมให้ดูสดใสขึ้น
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      localizationsDelegates: const [
        FirebaseUILocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('th', ''), // Thai
      ],
      home: const AuthGate(),
      debugShowCheckedModeBanner: false, // ปิดป้าย Debug เพื่อความสวยงาม
    );
  }
}
