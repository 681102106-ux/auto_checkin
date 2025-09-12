import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/student.dart';
import '../models/attendance.dart';

class CheckInScreen extends StatefulWidget {
  final Course course;
  // เราไม่ต้องการ scores Map อีกต่อไปแล้ว!

  const CheckInScreen({super.key, required this.course});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  // ... (ส่วนของข้อมูลนักเรียนและ initState เหมือนเดิม) ...
  final List<Student> _students = [
    Student(id: '68001', name: 'นายสมชาย ใจดี'),
    Student(id: '68002', name: 'นางสาวสมศรี มีสุข'),
  ];
  Map<String, AttendanceStatus> _attendanceData = {};

  @override
  void initState() {
    super.initState();
    for (var student in _students) {
      _attendanceData[student.id] = AttendanceStatus.unknown;
    }
  }

  // แก้ไขฟังก์ชันนี้ให้ใช้กฎจาก widget.course
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

  // ... (โค้ด build และ _buildStatusOption ที่เหลือเหมือนเดิมเป๊ะ) ...
  @override
  Widget build(BuildContext context) {
    // โค้ดส่วนนี้ไม่ต้องแก้ไขเลย! มันจะทำงานได้เอง!
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
