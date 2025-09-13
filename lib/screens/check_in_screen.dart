import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // <<<--- 1. Import เครื่องมือวิเศษเข้ามา
import '../models/course.dart';
import '../models/student.dart';
import '../models/attendance.dart';

class CheckInScreen extends StatefulWidget {
  final Course course;

  const CheckInScreen({super.key, required this.course});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  // ... (โค้ดส่วน State อื่นๆ เหมือนเดิมเป๊ะ) ...
  final List<Student> _students = [
    Student(id: '68001', name: 'นายสมชาย ใจดี'),
    Student(id: '68002', name: 'นางสาวสมศรี มีสุข'),
  ];
  final Map<String, AttendanceStatus> _attendanceData = {};

  @override
  void initState() {
    super.initState();
    for (var student in _students) {
      _attendanceData[student.id] = AttendanceStatus.unknown;
    }
  }

  double _getScoreForStatus(AttendanceStatus? status) {
    switch (status) {
      case AttendanceStatus.present:
        return widget.course.scoringRules.presentScore;
      case AttendanceStatus.absent:
        return widget.course.scoringRules.absentScore;
      case AttendanceStatus.onLeave:
        return widget.course.scoringRules.onLeaveScore;
      case AttendanceStatus.late:
        return widget.course.scoringRules.lateScore;
      default:
        return 0;
    }
  }

  // --- [โค้ดใหม่] ฟังก์ชันสำหรับแสดง Pop-up QR Code ---
  void _showQrCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min, // ทำให้ Column สูงเท่าที่จำเป็น
            children: [
              // 2. ใช้ QrImageView เพื่อสร้าง QR Code จาก ID ของคลาส
              QrImageView(
                data: widget.course.id, // ID ของคลาสคือข้อมูลที่เราจะเข้ารหัส
                version: QrVersions.auto,
                size: 200.0,
              ),
              const SizedBox(height: 20),
              const Text(
                'Class Code',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              // 3. แสดง Class ID เป็น Text ให้นักเรียนกรอกได้ด้วย
              SelectableText(widget.course.id),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  // --- [จบโค้ดใหม่] ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.name),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        // --- [โค้ดใหม่] เพิ่มปุ่ม Action ที่มุมขวาบน ---
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2),
            onPressed: _showQrCodeDialog, // 4. กดแล้วให้เรียกฟังก์ชันของเรา
            tooltip: 'Show Class QR Code',
          ),
        ],
        // --- [จบโค้ดใหม่] ---
      ),
      // ... (โค้ดส่วน body และ FloatingActionButton เหมือนเดิมเป๊ะ) ...
      body: ListView.builder(
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final student = _students[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${student.id} - ${student.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusOption(
                          student.id,
                          AttendanceStatus.present,
                          'มาเรียน',
                        ),
                      ),
                      Expanded(
                        child: _buildStatusOption(
                          student.id,
                          AttendanceStatus.absent,
                          'ขาด',
                        ),
                      ),
                      Expanded(
                        child: _buildStatusOption(
                          student.id,
                          AttendanceStatus.onLeave,
                          'ลา',
                        ),
                      ),
                      Expanded(
                        child: _buildStatusOption(
                          student.id,
                          AttendanceStatus.late,
                          'สาย',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'คะแนนที่ได้รับ: ${_getScoreForStatus(_attendanceData[student.id])}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          print(_attendanceData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('บันทึกการเช็คชื่อเรียบร้อย!')),
          );
        },
        label: const Text('บันทึก'),
        icon: const Icon(Icons.save),
      ),
    );
  }

  Widget _buildStatusOption(
    String studentId,
    AttendanceStatus status,
    String title,
  ) {
    return Column(
      children: [
        Radio<AttendanceStatus>(
          value: status,
          groupValue: _attendanceData[studentId],
          onChanged: (AttendanceStatus? value) {
            setState(() {
              if (value != null) {
                _attendanceData[studentId] = value;
              }
            });
          },
        ),
        Text(title),
      ],
    );
  }
}
