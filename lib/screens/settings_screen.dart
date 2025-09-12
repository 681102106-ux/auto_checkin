import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  // --- [โค้ดใหม่] สร้าง "ช่องรับ" ข้อมูลจาก HomeScreen ---
  final Map<String, double> initialScores;
  final Function(Map<String, double>) onScoresUpdated;

  const SettingsScreen({
    super.key,
    required this.initialScores,
    required this.onScoresUpdated,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // --- [โค้ดใหม่] State ตอนนี้จะคัดลอกค่ามาจาก "ช่องรับ" ---
  late Map<String, double> _currentScores;

  @override
  void initState() {
    super.initState();
    // คัดลอกค่าเริ่มต้นที่ได้รับมาเก็บไว้ใน State ของหน้านี้
    _currentScores = Map.from(widget.initialScores);
  }

  // ... (ฟังก์ชัน _showEditScoreDialog เหมือนเดิมเป๊ะ)
  Future<void> _showEditScoreDialog(
    String title,
    String key,
    double currentValue,
    Function(double) onSave,
  ) async {
    final TextEditingController scoreController = TextEditingController(
      text: currentValue.toString(),
    );
    // ... โค้ดส่วนที่เหลือของ Dialog เหมือนเดิม ...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        // --- [โค้ดใหม่] เพิ่มปุ่ม Save เพื่อส่งค่ากลับไปที่ HomeScreen ---
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // เรียกใช้ฟังก์ชันที่ได้รับมาจาก HomeScreen เพื่อส่งค่าใหม่กลับไป
              widget.onScoresUpdated(_currentScores);
              // แสดง SnackBar เพื่อยืนยัน
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('บันทึกการตั้งค่าแล้ว!')),
              );
              Navigator.of(context).pop(); // กลับไปหน้า Home
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // --- [แก้ไข] แก้ไข ListTile ทั้งหมดให้ใช้ State ใหม่ ---
          ListTile(
            title: const Text('มาเรียน'),
            trailing: Text('${_currentScores['present']} คะแนน'),
            onTap: () {
              _showEditScoreDialog(
                'มาเรียน',
                'present',
                _currentScores['present']!,
                (newScore) {
                  setState(() {
                    _currentScores['present'] = newScore;
                  });
                },
              );
            },
          ),
          // ... (แก้ไข ListTile ของ ขาด, ลา, สาย ในลักษณะเดียวกัน)
        ],
      ),
    );
  }
}
