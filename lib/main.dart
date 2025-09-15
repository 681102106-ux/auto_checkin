import 'package:auto_checkin/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart'; // Import for Cupertino localizations

// Standard Flutter and Firebase UI localization imports
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // โค้ดส่วนที่พยายามตั้งค่า fbaLabels ที่เป็นปัญหา ถูกลบออกไปแล้ว
    return MaterialApp(
      title: 'Auto Check-in',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // --- นี่คือส่วนที่อัปเดตตามสเปกครับ ---
      localizationsDelegates: [
        // Delegates for Firebase UI
        FirebaseUILocalizations.delegate,
        // Standard delegates for Flutter widgets
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate, // For iOS widgets
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('th', ''), // Thai
      ],
      // ตรวจสอบแล้วว่า home ยังคงเป็น AuthGate ถูกต้องตามสเปก
      home: const AuthGate(),
    );
  }
}
