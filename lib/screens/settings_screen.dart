import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  // สร้าง "ช่องรับ" ข้อมูลจาก HomeScreen
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
  // State ตอนนี้จะคัดลอกค่ามาจาก "ช่องรับ"
  // 'late' หมายถึงเราจะกำหนดค่าให้มันทีหลังใน initState
  late Map<String, double> _currentScores;

  @override
  void initState() {
    super.initState();
    // คัดลอกค่าเริ่มต้นที่ได้รับมา (widget.initialScores) เก็บไว้ใน State ของหน้านี้
    _currentScores = Map.from(widget.initialScores);
  }

  // ฟังก์ชันช่วยสร้าง Pop-up (เหมือนเดิม)
  Future<void> _showEditScoreDialog(
    String title,
    String key,
    Function(double) onSave,
  ) async {
    final TextEditingController scoreController = TextEditingController(
      text: _currentScores[key].toString(),
    );

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('แก้ไขคะแนนสำหรับ "$title"'),
          content: TextField(
            controller: scoreController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'คะแนนใหม่'),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('บันทึก'),
              onPressed: () {
                final double? newScore = double.tryParse(scoreController.text);
                if (newScore != null) {
                  onSave(newScore);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        // เพิ่มปุ่ม Save เพื่อส่งค่ากลับไปที่ HomeScreen
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // เรียกใช้ฟังก์ชันที่ได้รับมาจาก HomeScreen เพื่อส่งค่าใหม่กลับไป
              widget.onScoresUpdated(_currentScores);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('บันทึกการตั้งค่าเรียบร้อย!')),
              );
              Navigator.of(context).pop(); // กลับไปหน้า Home
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // แก้ไข ListTile ทั้งหมดให้ใช้ State ใหม่ (_currentScores)
          ListTile(
            leading: const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
            ),
            title: const Text('มาเรียน'),
            trailing: Text('${_currentScores['present']} คะแนน'),
            onTap: () {
              _showEditScoreDialog('มาเรียน', 'present', (newScore) {
                setState(() {
                  _currentScores['present'] = newScore;
                });
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.cancel_outlined, color: Colors.red),
            title: const Text('ขาด'),
            trailing: Text('${_currentScores['absent']} คะแนน'),
            onTap: () {
              _showEditScoreDialog('ขาด', 'absent', (newScore) {
                setState(() {
                  _currentScores['absent'] = newScore;
                });
              });
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.description_outlined,
              color: Colors.orange,
            ),
            title: const Text('ลา'),
            trailing: Text('${_currentScores['onLeave']} คะแนน'),
            onTap: () {
              _showEditScoreDialog('ลา', 'onLeave', (newScore) {
                setState(() {
                  _currentScores['onLeave'] = newScore;
                });
              });
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.watch_later_outlined,
              color: Colors.blueGrey,
            ),
            title: const Text('มาสาย'),
            trailing: Text('${_currentScores['late']} คะแนน'),
            onTap: () {
              _showEditScoreDialog('มาสาย', 'late', (newScore) {
                setState(() {
                  _currentScores['late'] = newScore;
                });
              });
            },
          ),
        ],
      ),
    );
  }
}
