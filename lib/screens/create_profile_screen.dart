import 'package.auto_checkin/services/firestore_service.dart';
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

  Future<void> _saveProfile() async {
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
          // AuthGate จะจัดการเรื่องการเปลี่ยนหน้าให้เองเมื่อ State เปลี่ยน
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
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
            ),
            TextFormField(
              controller: _studentIdController,
              decoration: const InputDecoration(labelText: 'รหัสนักศึกษา'),
            ),
            TextFormField(
              controller: _facultyController,
              decoration: const InputDecoration(labelText: 'คณะ'),
            ),
            TextFormField(
              controller: _majorController,
              decoration: const InputDecoration(labelText: 'สาขา'),
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
            ),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'เบอร์โทรติดต่อ'),
              keyboardType: TextInputType.phone,
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
