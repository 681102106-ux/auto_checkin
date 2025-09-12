import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatelessWidget {
  const QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Class QR Code')),
      body: MobileScanner(
        // controller: MobileScannerController(
        //   detectionSpeed: DetectionSpeed.noDuplicates, // ป้องกันการสแกนซ้ำๆ
        // ),
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final String scannedCode = barcodes.first.rawValue ?? "Error";
            // เมื่อสแกนเจอ ให้ส่ง "รหัสที่สแกนได้" กลับไปหน้าก่อนหน้า
            Navigator.of(context).pop(scannedCode);
          }
        },
      ),
    );
  }
}
