import 'package.auto_checkin/models/attendance.dart';
import 'package:auto_checkin/models/attendance_record.dart';
import 'package:auto_checkin/models/student_profile.dart';
import 'package:auto_checkin/services/firestore_service.dart';
import 'package:auto_checkin/widgets/attendance_summary_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  late Future<List<StudentProfile>> _rosterFuture;

  @override
  void initState() {
    super.initState();
    _rosterFuture = _firestoreService.getStudentsInCourse(
      widget.course.studentUids,
    );
  }

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
                data: widget.course.id, // QR Code ยังคงใช้ ID ที่ไม่ซ้ำกัน
                version: QrVersions.auto,
                size: 200.0,
              ),
              const SizedBox(height: 16),
              const Text(
                'Join Code',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              // --- [จุดแก้ไข!] แสดง joinCode ที่อ่านง่าย ---
              SelectableText(
                widget.course.joinCode,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
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

  void _markStudentAs(StudentProfile student, AttendanceStatus status) {
    final newRecord = AttendanceRecord(
      id: '',
      courseId: widget.course.id,
      studentUid: student.uid,
      studentId: student.studentId,
      studentName: student.fullName,
      checkInTime: Timestamp.now(),
      status: status,
    );
    _firestoreService.createAttendanceRecord(
      courseId: widget.course.id,
      record: newRecord,
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
            tooltip: 'Show QR Code',
          ),
        ],
      ),
      body: FutureBuilder<List<StudentProfile>>(
        future: _rosterFuture,
        builder: (context, rosterSnapshot) {
          if (rosterSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (rosterSnapshot.hasError) {
            return Center(
              child: Text('Error loading roster: ${rosterSnapshot.error}'),
            );
          }
          if (!rosterSnapshot.hasData || rosterSnapshot.data!.isEmpty) {
            return const Center(
              child: Text('No students enrolled in this course.'),
            );
          }

          final roster = rosterSnapshot.data!;

          return StreamBuilder<List<AttendanceRecord>>(
            stream: _firestoreService.getAttendanceStream(widget.course.id),
            builder: (context, attendanceSnapshot) {
              final records = attendanceSnapshot.data ?? [];
              final attendanceMap = {for (var r in records) r.studentUid: r};

              int presentCount = 0;
              int onLeaveCount = 0;
              int lateCount = 0;

              for (var rec in records) {
                if (rec.status == AttendanceStatus.present) presentCount++;
                if (rec.status == AttendanceStatus.onLeave) onLeaveCount++;
                if (rec.status == AttendanceStatus.late) lateCount++;
              }

              int checkedInCount = records.length;
              final int absentCount = roster.length - checkedInCount;

              return Column(
                children: [
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
                          count: absentCount > 0 ? absentCount : 0,
                          icon: Icons.cancel,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: roster.length,
                      itemBuilder: (context, index) {
                        final student = roster[index];
                        final record = attendanceMap[student.uid];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          color: record == null ? Colors.red.shade50 : null,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${student.studentId} - ${student.fullName}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (record != null)
                                  Text(
                                    'Checked-in at: ${DateFormat('HH:mm:ss').format(record.checkInTime.toDate())}',
                                  ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: AttendanceStatus.values
                                      .where(
                                        (s) => s != AttendanceStatus.unknown,
                                      )
                                      .map((status) {
                                        return Column(
                                          children: [
                                            Radio<AttendanceStatus>(
                                              value: status,
                                              groupValue:
                                                  record?.status ??
                                                  AttendanceStatus.absent,
                                              onChanged: (value) {
                                                if (value != null) {
                                                  if (record != null) {
                                                    _updateStudentStatus(
                                                      record,
                                                      value,
                                                    );
                                                  } else {
                                                    _markStudentAs(
                                                      student,
                                                      value,
                                                    );
                                                  }
                                                }
                                              },
                                            ),
                                            Text(
                                              status.toString().split('.').last,
                                            ),
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
                ],
              );
            },
          );
        },
      ),
    );
  }
}
