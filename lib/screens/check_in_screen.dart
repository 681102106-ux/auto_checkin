import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/student.dart';
import '../models/attendance.dart';

class CheckInScreen extends StatefulWidget {
  final Course course;
  final Map<String, double> scores;

  const CheckInScreen({super.key, required this.course, required this.scores});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final List<Student> _students = [
    Student(id: '68001', name: 'นายสมชาย ใจดี'),
    Student(id: '68002', name: 'นางสาวสมศรี มีสุข'),
    Student(id: '68003', name: 'นายมานะ อดทน'),
    Student(id: '68004', name: 'นางสาวปิติ ยินดี'),
    Student(id: '68005', name: 'เด็กหญิงอารี รักเรียน'),
  ];

  Map<String, AttendanceStatus> _attendanceData = {};

  @override
  void initState() {
    super.initState();
    for (var student in _students) {
      _attendanceData[student.id] = AttendanceStatus.present;
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
                    // [FIX 1] แก้ไข UI ที่ไม่สมดุล
                    // เราจะใช้ Expanded เพื่อให้แต่ละตัวเลือกมีขนาดเท่ากัน
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
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
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
              _attendanceData[studentId] = value!;
            });
          },
        ),
        Text(title),
      ],
    );
  }
}
