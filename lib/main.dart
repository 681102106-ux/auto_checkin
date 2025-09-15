import 'package:auto_checkin/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- เพิ่มระบบตรวจสอบการเชื่อมต่อ Firebase ---
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // ถ้าสำเร็จ ให้พิมพ์ข้อความนี้ใน Console
    print("Firebase initialized successfully!");
  } catch (e) {
    // ถ้าล้มเหลว ให้พิมพ์ Error ออกมา
    print("ERROR initializing Firebase: $e");
  }
  // ------------------------------------------

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Check-in',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      localizationsDelegates: const [
        FirebaseUILocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('th', '')],
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}
