import 'package:auto_checkin/models/attendance.dart';
import 'package:auto_checkin/models/attendance_record.dart';
import 'package:auto_checkin/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/course.dart';

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

  void _updateStudentStatus(
    AttendanceRecord record,
    AttendanceStatus newStatus,
  ) {
    _firestoreService.updateAttendanceStatus(
      courseId: widget.course.id,
      recordId: record.id,
      newStatus: newStatus.toString().split('.').last,
    );
  }

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
      body: StreamBuilder<List<AttendanceRecord>>(
        // "เงี่ยหูฟัง" รายชื่อผู้เข้าเรียนของคลาสนี้
        stream: _firestoreService.getAttendanceStream(widget.course.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No students have checked in yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final records = snapshot.data!;

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${record.studentId} - ${record.studentName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Checked-in at: ${record.checkInTime.toDate().toLocal()}',
                      ),
                      const Divider(),
                      // ส่วนของ Radio Button สำหรับอาจารย์แก้ไข
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: AttendanceStatus.values
                            .where((s) => s != AttendanceStatus.unknown)
                            .map((status) {
                              return Column(
                                children: [
                                  Radio<AttendanceStatus>(
                                    value: status,
                                    groupValue: record.status,
                                    onChanged: (value) {
                                      if (value != null) {
                                        _updateStudentStatus(record, value);
                                      }
                                    },
                                  ),
                                  Text(status.toString().split('.').last),
                                ],
                              );
                            })
                            .toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
