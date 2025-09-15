import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert'; // Import this to use jsonEncode

class GenerateQRScreen extends StatelessWidget {
  final String courseId;
  final String courseName;
  final String sessionId; // เพิ่ม sessionId เข้ามา

  const GenerateQRScreen({
    Key? key,
    required this.courseId,
    required this.courseName,
    required this.sessionId, // ทำให้ sessionId เป็นค่าที่ต้องรับเข้ามา
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // สร้างข้อมูลที่จะฝังใน QR Code ในรูปแบบ JSON
    final qrData = jsonEncode({'courseId': courseId, 'sessionId': sessionId});

    return Scaffold(
      appBar: AppBar(title: Text('QR Code for $courseName')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrData, // ใช้ข้อมูล JSON ที่เราสร้างขึ้น
              version: QrVersions.auto,
              size: 250.0,
            ),
            const SizedBox(height: 20),
            Text(
              'Scan this QR code to check-in',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text('Session ID: $sessionId'),
          ],
        ),
      ),
    );
  }
}
