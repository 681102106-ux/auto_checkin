import 'package:flutter/material.dart';
// แก้ไข import
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({Key? key}) : super(key: key);

  @override
  _ScanQRScreenState createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;

  @override
  void reassemble() {
    super.reassemble();
    controller?.pauseCamera();
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.deepPurple,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 300,
            ),
          ),
          if (_isProcessing) const CircularProgressIndicator(),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_isProcessing && scanData.code != null) {
        setState(() {
          _isProcessing = true;
        });
        controller.pauseCamera();
        _handleScannedData(scanData.code!);
      }
    });
  }

  Future<void> _handleScannedData(String qrData) async {
    try {
      final data = jsonDecode(qrData);
      final courseId = data['courseId'];
      final professorId = data['professorId'];

      if (courseId == null || professorId == null) {
        throw Exception("Invalid QR code format.");
      }

      final student = FirebaseAuth.instance.currentUser;
      if (student == null) {
        throw Exception("You must be logged in to check-in.");
      }

      final studentRef = _getStudentMasterRef(professorId, student.uid);
      final studentDoc = await studentRef.get();

      bool isNewlyRegistered = false;
      if (!studentDoc.exists) {
        final bool? registered = await _showRegistrationDialog(
          studentRef,
          student,
        );
        if (registered == null || !registered) {
          throw Exception("Registration cancelled.");
        }
        isNewlyRegistered = true;
      }

      if (isNewlyRegistered) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final studentMasterData =
          (await studentRef.get()).data() as Map<String, dynamic>?;

      if (studentMasterData == null) {
        throw Exception("Failed to retrieve student data after registration.");
      }

      await _createPendingCheckIn(courseId, student, studentMasterData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check-in request sent! Waiting for approval.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      // Allow user to scan again after a delay if something went wrong and they are still on the page
      if (mounted) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _isProcessing = false;
            });
            controller?.resumeCamera();
          }
        });
      }
    }
  }

  DocumentReference _getStudentMasterRef(String professorId, String studentId) {
    return FirebaseFirestore.instance
        .collection('professors')
        .doc(professorId)
        .collection('students')
        .doc(studentId);
  }

  Future<void> _createPendingCheckIn(
    String courseId,
    User student,
    Map<String, dynamic> studentData,
  ) async {
    final rosterRef = FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('roster')
        .doc(student.uid);

    await rosterRef.set({
      'student_uid': student.uid,
      'student_name': studentData['name'],
      'student_id': studentData['student_id_number'],
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<bool?> _showRegistrationDialog(
    DocumentReference studentRef,
    User student,
  ) async {
    final nameController = TextEditingController();
    final studentIdController = TextEditingController();
    String? selectedYear;
    final formKey = GlobalKey<FormState>();

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('First-Time Registration'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: studentIdController,
                        decoration: const InputDecoration(
                          labelText: 'Student ID',
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedYear,
                        hint: const Text('Select Year'),
                        onChanged: (value) {
                          setDialogState(() => selectedYear = value);
                        },
                        items: ['1', '2', '3', '4', 'Other']
                            .map(
                              (year) => DropdownMenuItem(
                                value: year,
                                child: Text('Year $year'),
                              ),
                            )
                            .toList(),
                        validator: (v) =>
                            v == null ? 'Please select a year' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await studentRef.set({
                        'name': nameController.text.trim(),
                        'student_id_number': studentIdController.text.trim(),
                        'year': selectedYear,
                        'email': student.email,
                        'registered_at': FieldValue.serverTimestamp(),
                      });
                      Navigator.pop(context, true);
                    }
                  },
                  child: const Text('Register'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
