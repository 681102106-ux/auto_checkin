import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 1. สร้าง "State" เพื่อเก็บค่าคะแนนเริ่มต้น
  double _presentScore = 1.0;
  double _absentScore = 0.0;
  double _onLeaveScore = 0.5;
  double _lateScore = 0.75; // สมมติค่าเริ่มต้นของ 'สาย'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // --- ใช้ ListTile ในการแสดงผลแต่ละรายการตั้งค่า ---
          ListTile(
            leading: const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
            ),
            title: const Text('มาเรียน'),
            trailing: Text('$_presentScore คะแนน'),
            onTap: () {
              // TODO: Add edit functionality
            },
          ),
          ListTile(
            leading: const Icon(Icons.cancel_outlined, color: Colors.red),
            title: const Text('ขาด'),
            trailing: Text('$_absentScore คะแนน'),
            onTap: () {
              // TODO: Add edit functionality
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.description_outlined,
              color: Colors.orange,
            ),
            title: const Text('ลา'),
            trailing: Text('$_onLeaveScore คะแนน'),
            onTap: () {
              // TODO: Add edit functionality
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.watch_later_outlined,
              color: Colors.blueGrey,
            ),
            title: const Text('มาสาย'),
            trailing: Text('$_lateScore คะแนน'),
            onTap: () {
              // TODO: Add edit functionality
            },
          ),
        ],
      ),
    );
  }
}
