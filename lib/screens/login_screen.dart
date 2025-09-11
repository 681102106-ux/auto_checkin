import 'package:flutter/material.dart';
import 'home_screen.dart';

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_pin_circle_outlined,
              size: 100,
              color: Colors.indigo,
            ),
            const SizedBox(height: 40),

            // --- ช่องกรอกที่ผูกกับ Controller แล้ว ---
            TextField(
              controller: _idController, // ผูก "สายจูง" เส้นที่ 1
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
              controller: _passwordController, // ผูก "สายจูง" เส้นที่ 2
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

            // --- ปุ่มที่มีชีวิตแล้ว! ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // อ่านค่าจากช่องข้อความผ่าน controller
                  final String userId = _idController.text;
                  final String password = _passwordController.text;

                  // แสดงผลใน Console เพื่อเช็กว่าเราอ่านค่าได้จริง
                  print('User ID: $userId');
                  print('Password: $password');

                  // คำสั่งนำทางไปยังหน้า Home
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
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
    );
  }
}
