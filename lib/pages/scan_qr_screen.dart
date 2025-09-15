import 'dart:convert';
import 'package:auto_checkin/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({Key? key}) : super(key: key);

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isProcessing = false;

  void _handleQrCode(BuildContext context, String rawValue) async {
    if (_isProcessing) return; // Prevent multiple submissions

    setState(() {
      _isProcessing = true;
    });

    final user = _auth.currentUser;
    if (user == null) {
      _showErrorDialog("You must be logged in to check in.");
      return;
    }

    try {
      // Decode JSON from the QR code
      final data = jsonDecode(rawValue) as Map<String, dynamic>;
      final courseId = data['courseId'] as String?;
      final sessionId = data['sessionId'] as String?;

      if (courseId == null || sessionId == null) {
        throw const FormatException("Invalid QR code data.");
      }

      // Create the attendance record
      await _firestoreService.createAttendanceRecord(
        courseId: courseId,
        sessionId: sessionId,
        student: user,
      );

      // Show success message and close the scanner
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Check-in Successful!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FormatException catch (_) {
      _showErrorDialog(
        "Invalid QR Code format. Please scan a valid check-in QR code.",
      );
    } catch (e) {
      _showErrorDialog("An error occurred: $e");
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Check-in Failed'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
              // Reset state to allow scanning again
              if (mounted) {
                setState(() {
                  _isProcessing = false;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan to Check-in')),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_isProcessing) return;
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                _handleQrCode(context, barcodes.first.rawValue!);
              }
            },
          ),
          // UI Overlay
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 4),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
