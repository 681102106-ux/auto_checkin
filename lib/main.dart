import 'package:auto_checkin/auth_gate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart'; // <<<--- Import เข้ามา
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- [เพิ่มเข้ามา] กำหนด Label ภาษาไทย ---
    final fbaLabels = FirebaseUILocalizations.labels;
    fbaLabels[DefaultLocalizations.of(context).locale.languageCode] =
        ThaiFirebaseUILocalizations();
    // --- [จบส่วนที่เพิ่ม] ---

    return MaterialApp(
      title: 'Auto Check-in App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      // --- [เพิ่มเข้ามา] บอกให้แอปใช้เมนูภาษาไทย ---
      localizationsDelegates: [FirebaseUILocalizations.delegate],
      // --- [จบส่วนที่เพิ่ม] ---
      home: const AuthGate(),
    );
  }
}
