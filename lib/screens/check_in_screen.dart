import 'package:auto_checkin/models/attendance.dart';
import 'package:auto_checkin/models/attendance_record.dart';
import 'package:auto_checkin/services/firestore_service.dart';
import 'package:auto_checkin/widgets/attendance_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/course.dart';
import 'package:intl/intl.dart';

class CheckInScreen extends StatefulWidget {
  final Course course;
  const CheckInScreen({super.key, required this.course});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _showQrCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: widget.course.id,
                version: QrVersions.auto,
                size: 200.0,
              ),
              const SizedBox(height: 20),
              const Text(
                'Class Code',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
        title: Text('Check-in: ${widget.course.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2),
            onPressed: _showQrCodeDialog,
          ),
        ],
      ),
      body: StreamBuilder<List<AttendanceRecord>>(
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

          // คำนวณผลสรุป
          final int presentCount = records
              .where((r) => r.status == AttendanceStatus.present)
              .length;
          final int absentCount = 0; // ในอนาคตเราต้องดึงรายชื่อ นศ ทั้งหมดมาลบ
          final int onLeaveCount = records
              .where((r) => r.status == AttendanceStatus.onLeave)
              .length;
          final int lateCount = records
              .where((r) => r.status == AttendanceStatus.late)
              .length;

          // ใช้ Column หุ้มทั้งหมดเพื่อให้มี Dashboard อยู่บนสุด
          return Column(
            children: [
              // --- ส่วนของแดชบอร์ด ---
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    AttendanceSummaryCard(
                      title: 'Present',
                      count: presentCount,
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                    AttendanceSummaryCard(
                      title: 'Late',
                      count: lateCount,
                      icon: Icons.watch_later,
                      color: Colors.blueGrey,
                    ),
                    AttendanceSummaryCard(
                      title: 'On Leave',
                      count: onLeaveCount,
                      icon: Icons.description,
                      color: Colors.orange,
                    ),
                    AttendanceSummaryCard(
                      title: 'Absent',
                      count: absentCount,
                      icon: Icons.cancel,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
              const Divider(),
              // --- [จบส่วนแดชบอร์ด] ---

              // --- ส่วนของรายชื่อนักเรียน ---
              // ใช้ Expanded เพื่อบอกให้ ListView ใช้พื้นที่ที่เหลือทั้งหมด
              Expanded(
                child: ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
                              'Checked-in at: ${DateFormat('HH:mm:ss').format(record.checkInTime.toDate())}',
                            ),
                            const Divider(),
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
                                              _updateStudentStatus(
                                                record,
                                                value,
                                              );
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
                ),
              ),
              // --- [จบส่วนรายชื่อ] ---
            ],
          );
        },
      ),
    );
  }
}
