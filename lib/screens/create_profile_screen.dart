import 'package:auto_checkin/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _facultyController = TextEditingController();
  final _majorController = TextEditingController();
  final _phoneController = TextEditingController();
  int? _selectedYear = 1;

  bool _isLoading = false;

  @override
  void dispose() {
    _studentIdController.dispose();
    _fullNameController.dispose();
    _facultyController.dispose();
    _majorController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    // ป้องกันการกดปุ่มซ้ำ
    if (_isLoading) return;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirestoreService().updateStudentProfile(
            uid: user.uid,
            studentId: _studentIdController.text.trim(),
            fullName: _fullNameController.text.trim(),
            faculty: _facultyController.text.trim(),
            major: _majorController.text.trim(),
            year: _selectedYear!,
            phoneNumber: _phoneController.text.trim(),
          );
          // --- [จุดแก้ไขที่สำคัญที่สุด!] ---
          // เมื่อสำเร็จแล้ว เราไม่ต้องทำอะไรต่อเลย!
          // เพราะ AuthGate จะจัดการเปลี่ยนหน้าให้เราเอง
          // ไม่ต้องมี setState((){ _isLoading = false; }) ตรงนี้แล้ว
        }
      } catch (e) {
        // เราจะหยุดโหลดก็ต่อเมื่อเกิด Error เท่านั้น
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
        }
      }
      // เอา finally ออกไป เพราะเราจะจัดการ State ใน try/catch แทน
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Your Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'ชื่อ-นามสกุล'),
              validator: (value) =>
                  value!.isEmpty ? 'กรุณากรอกชื่อ-นามสกุล' : null,
            ),
            TextFormField(
              controller: _studentIdController,
              decoration: const InputDecoration(labelText: 'รหัสนักศึกษา'),
              validator: (value) =>
                  value!.isEmpty ? 'กรุณากรอกรหัสนักศึกษา' : null,
            ),
            TextFormField(
              controller: _facultyController,
              decoration: const InputDecoration(labelText: 'คณะ'),
              validator: (value) => value!.isEmpty ? 'กรุณากรอกคณะ' : null,
            ),
            TextFormField(
              controller: _majorController,
              decoration: const InputDecoration(labelText: 'สาขา'),
              validator: (value) => value!.isEmpty ? 'กรุณากรอกสาขา' : null,
            ),
            DropdownButtonFormField<int>(
              value: _selectedYear,
              decoration: const InputDecoration(labelText: 'ชั้นปี'),
              items: [1, 2, 3, 4].map((int year) {
                return DropdownMenuItem<int>(
                  value: year,
                  child: Text('ปี $year'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  _selectedYear = newValue;
                });
              },
              validator: (value) => value == null ? 'กรุณาเลือกชั้นปี' : null,
            ),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'เบอร์โทรติดต่อ'),
              keyboardType: TextInputType.phone,
              validator: (value) => value!.isEmpty ? 'กรุณากรอกเบอร์โทร' : null,
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Save Profile'),
                  ),
          ],
        ),
      ),
    );
  }
}
