import 'package:flutter/material.dart';
import '../models/user_role.dart';
import 'home_screen.dart';
import 'student_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final String userId = _idController.text;
    final String password = _passwordController.text;

    // --- [จุดที่แก้ไข] เปลี่ยนจากการบังคับ Role มาเป็นการตรวจสอบ ID/Pass ---
    UserRole? userRole; // สร้างตัวแปร Role ที่อาจจะว่างได้ (nullable)

    // ตรวจสอบเงื่อนไขของ Professor
    if (userId == 'narasak' && password == '0') {
      userRole = UserRole.professor;
    }
    // ตรวจสอบเงื่อนไขของ Student
    else if (userId == '0' && password == '0') {
      userRole = UserRole.student;
    }

    // --- Logic การเปลี่ยนหน้า และจัดการ Error ---
    if (userRole != null) {
      // ถ้า Login ถูกต้อง (userRole ไม่ใช่ค่าว่าง)
      switch (userRole) {
        case UserRole.professor:
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
          break;
        case UserRole.student:
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const StudentScreen()),
          );
          break;
      }
    } else {
      // ถ้า Login ผิดพลาด (userRole ยังเป็นค่าว่างอยู่)
      // ให้แสดง SnackBar แจ้งเตือน
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('รหัสประจำตัวหรือรหัสผ่านไม่ถูกต้อง!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Check-in | Login'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          // ใช้ SingleChildScrollView ป้องกันคีย์บอร์ดล้น
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.person_pin_circle_outlined,
                size: 100,
                color: Colors.indigo,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: 'รหัสประจำตัว',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'รหัสผ่าน',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('ล็อกอิน', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
