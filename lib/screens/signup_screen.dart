import 'package:auto_checkin/services/firestore_service.dart'; // <<<--- 1. Import พ่อครัวใหญ่
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_role.dart'; // <<<--- 2. Import UserRole

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // --- [โค้ดใหม่] สร้าง State สำหรับเลือกว่าจะสมัครเป็น Professor หรือ Student ---
  UserRole _selectedRole = UserRole.student;

  Future<void> _signUp() async {
    // ... (ส่วน Validation เหมือนเดิม) ...
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      /* ... */
      return;
    }
    if (password.length < 6) {
      /* ... */
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. สร้าง User ในระบบ Authentication
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // 2. ถ้าสร้างสำเร็จ ให้เรียก "พ่อครัวใหญ่" มาสร้างข้อมูลใน Firestore
      if (userCredential.user != null) {
        await FirestoreService().createUser(
          uid: userCredential.user!.uid,
          email: email,
          role: _selectedRole, // <<<--- 3. ส่ง Role ที่เลือกไปบันทึก
        );
      }

      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message ?? "Sign up failed")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ... (dispose method เหมือนเดิม) ...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ... (ช่องกรอก Email, Password เหมือนเดิม) ...

            // --- [โค้ดใหม่] เพิ่มตัวเลือก Role ---
            const SizedBox(height: 20),
            Text('Sign up as:', style: Theme.of(context).textTheme.titleMedium),
            RadioListTile<UserRole>(
              title: const Text('Student'),
              value: UserRole.student,
              groupValue: _selectedRole,
              onChanged: (UserRole? value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
            RadioListTile<UserRole>(
              title: const Text('Professor'),
              value: UserRole.professor,
              groupValue: _selectedRole,
              onChanged: (UserRole? value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),

            // --- [จบโค้ดใหม่] ---
            const SizedBox(height: 40),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _signUp,
                    child: const Text('Sign Up'),
                  ),
          ],
        ),
      ),
    );
  }
}
