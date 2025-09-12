import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/student.dart';
import '../models/attendance.dart';

class CheckInScreen extends StatefulWidget {
  final Course course;
  // เพิ่มช่องรับคะแนน
  final Map<String, double> scores;

  const CheckInScreen({
    super.key,
    required this.course,
    required this.scores, // เพิ่มเข้ามาใน constructor
  });

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final List<Student> _students = [
    Student(id: '68001', name: 'นายสมชาย ใจดี'),
    Student(id: '68002', name: 'นางสาวสมศรี มีสุข'),
    Student(id: '68003', name: 'นายมานะ อดทน'),
  ];

  Map<String, AttendanceStatus> _attendanceData = {};

  @override
  void initState() {
    super.initState();
    for (var student in _students) {
      // ตั้งค่าเริ่มต้นเป็น unknown ตามที่คุณทำไว้
      _attendanceData[student.id] = AttendanceStatus.unknown;
    }
  }

  // --- [เพิ่มเข้ามา] ฟังก์ชันผู้ช่วยแปลงสถานะเป็นคะแนน ---
  double _getScoreForStatus(AttendanceStatus? status) {
    // widget.scores คือการเข้าถึง "scores" ที่ถูกส่งมาจาก HomeScreen
    switch (status) {
      case AttendanceStatus.present:
        return widget.scores['present'] ?? 0;
      case AttendanceStatus.absent:
        return widget.scores['absent'] ?? 0;
      case AttendanceStatus.onLeave:
        return widget.scores['onLeave'] ?? 0;
      case AttendanceStatus.late:
        return widget.scores['late'] ?? 0;
      default:
        return 0; // กรณีที่ไม่พบสถานะ (เช่น unknown)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.name),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
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
                  // --- [เพิ่มเข้ามา] ส่วนแสดงคะแนนเพื่อ "พิสูจน์" ---
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
