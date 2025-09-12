import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/student.dart';
import '../models/attendance.dart'; // Import Attendance Model

class CheckInScreen extends StatefulWidget {
  final Course course;
  final Map<String, double> scores;

  const CheckInScreen({super.key, required this.course, required this.scores});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  // 1. สร้าง "ข้อมูลจำลอง" ของนักเรียนในวิชานี้
  final List<Student> _students = [
    Student(id: '681102106', name: 'นายเจฟสุดหล่อ คนดี100000%'),
    Student(id: '68002', name: 'นางสาวสมศรี มีสุข'),
    Student(id: '68003', name: 'นายมานะ อดทน'),
    Student(id: '68004', name: 'นางสาวปิติ ยินดี'),
    Student(id: '68005', name: 'เด็กหญิงอารี รักเรียน'),
  ];

  // 2. สร้าง "สมุดจด" เพื่อบันทึกสถานะของนักเรียนแต่ละคน
  // Key คือ ID ของนักเรียน, Value คือสถานะการเข้าเรียน
  // เราจะตั้งค่าเริ่มต้นให้ทุกคนเป็น "มาเรียน" (present)
  Map<String, AttendanceStatus> _attendanceData = {};

  // initState คือฟังก์ชันที่จะทำงานแค่ "ครั้งเดียว" ตอนที่หน้านี้ถูกเปิดขึ้นมา
  @override
  void initState() {
    super.initState();
    // วนลูปเพื่อตั้งค่าสถานะเริ่มต้นให้นักเรียนทุกคน
    for (var student in _students) {
      _attendanceData[student.id] = AttendanceStatus.present;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.course.name,
        ), // widget.course ใช้เพื่อเข้าถึงข้อมูลจาก class แม่
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final student = _students[index];

          // Card ช่วยทำให้ UI ดูมีมิติและแบ่งสัดส่วนได้สวยงาม
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- ส่วนแสดงชื่อนักเรียน ---
                  Text(
                    '${student.id} - ${student.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),

                  // --- ส่วนของ Radio Button ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatusOption(
                        student.id,
                        AttendanceStatus.present,
                        'มาเรียน',
                      ),
                      _buildStatusOption(
                        student.id,
                        AttendanceStatus.absent,
                        'ขาด',
                      ),
                      _buildStatusOption(
                        student.id,
                        AttendanceStatus.onLeave,
                        'ลา',
                      ),
                      _buildStatusOption(
                        student.id,
                        AttendanceStatus.late,
                        'สาย',
                      ),
                      const SizedBox(height: 8), // เพิ่มระยะห่างนิดหน่อย
                      // เราจะใช้ widget.scores เพื่อดึงค่าคะแนนที่ถูกส่งเข้ามา
                      Text(
                        'คะแนนที่ได้รับ: ${_getScoreForStatus(_attendanceData[student.id])}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold,
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
      // เพิ่มปุ่มสำหรับ "บันทึก" การเช็คชื่อ
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: เพิ่ม Logic การบันทึกข้อมูลลงฐานข้อมูล
          print(_attendanceData); // แสดงผลข้อมูลการเช็คชื่อใน Console
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

  // ฟังก์ชันช่วยสร้าง Radio Button เพื่อลดการเขียนโค้ดซ้ำซ้อน
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
            // setState คือคำสั่งศักดิ์สิทธิ์!
            // ใช้เพื่อบอกให้ Flutter "สร้าง UI ใหม่" หลังจากข้อมูลเปลี่ยนแปลง
            setState(() {
              _attendanceData[studentId] = value!;
            });
          },
        ),
        Text(title),
      ],
    );
  }

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

  // ---------------------------------
}
