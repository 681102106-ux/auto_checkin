import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQRScreen extends StatefulWidget {
  final String courseId;
  final String professorId;

  const ScanQRScreen({
    Key? key,
    required this.courseId,
    required this.professorId,
  }) : super(key: key);

  @override
  _ScanQRScreenState createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  final MobileScannerController controller = MobileScannerController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? qrData = barcodes.first.rawValue;
      if (qrData != null) {
        final parts = qrData.split(',');
        if (parts.length == 2 &&
            parts[0] == widget.courseId &&
            parts[1] == widget.professorId) {
          _processCheckIn();
        } else {
          _showErrorDialog(
            'Invalid QR Code',
            'This QR code is not for this course.',
          );
        }
      }
    }
  }

  Future<void> _processCheckIn() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      DocumentReference studentInProfRosterRef = _firestore
          .collection('professors')
          .doc(widget.professorId)
          .collection('students')
          .doc(user.uid);

      final studentDoc = await studentInProfRosterRef.get();

      if (!studentDoc.exists) {
        await _showRegistrationDialog(studentInProfRosterRef);
      }

      await _createPendingCheckIn(user.uid);
    } catch (e) {
      _showErrorDialog('Error', 'An unexpected error occurred: $e');
    }
  }

  Future<void> _createPendingCheckIn(String studentUid) async {
    final userDoc = await _firestore
        .collection('professors')
        .doc(widget.professorId)
        .collection('students')
        .doc(studentUid)
        .get();
    final studentName = userDoc.data()?['student_name'] ?? 'Unknown Student';
    final studentId = userDoc.data()?['student_id'] ?? 'Unknown ID';

    await _firestore
        .collection('courses')
        .doc(widget.courseId)
        .collection('roster')
        .doc(studentUid)
        .set({
          'student_uid': studentUid,
          'student_name': studentName,
          'student_id': studentId,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'pending',
        });

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Check-in request sent! Waiting for approval.'),
      ),
    );
  }

  Future<void> _showRegistrationDialog(DocumentReference docRef) async {
    final nameController = TextEditingController();
    final idController = TextEditingController();
    String? selectedYear;
    final years = ['1', '2', '3', '4', 'Other'];

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('First-time Registration'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Please enter your details to register with this professor.',
                    ),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                    ),
                    TextField(
                      controller: idController,
                      decoration: const InputDecoration(
                        labelText: 'Student ID',
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedYear,
                      hint: const Text('Select Year'),
                      onChanged: (value) {
                        setState(() {
                          selectedYear = value;
                        });
                      },
                      items: years.map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text('Year $year'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    idController.text.isNotEmpty &&
                    selectedYear != null) {
                  await docRef.set({
                    'student_name': nameController.text,
                    'student_id': idController.text,
                    'year': selectedYear,
                    'registered_at': FieldValue.serverTimestamp(),
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Register'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isProcessing = false;
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: Stack(
        children: [
          MobileScanner(controller: controller, onDetect: _handleBarcode),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_isProcessing) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
