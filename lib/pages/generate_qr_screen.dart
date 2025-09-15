import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

class GenerateQRScreen extends StatelessWidget {
  final String courseId;
  final String professorId;

  const GenerateQRScreen({
    Key? key,
    required this.courseId,
    required this.professorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // สร้างข้อมูลที่จะใส่ใน QR Code (ในรูปแบบ JSON String)
    final qrData = jsonEncode({
      'courseId': courseId,
      'professorId': professorId,
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in QR Code'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 250.0,
              embeddedImageStyle: const QrEmbeddedImageStyle(
                size: Size(80, 80),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Scan this code to check-in',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
