import 'package:auto_checkin/models/checkin_session.dart';
import 'package:auto_checkin/models/course.dart';
import 'package:auto_checkin/pages/check_in_screen.dart';
import 'package:auto_checkin/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;
  const CourseDetailScreen({Key? key, required this.course}) : super(key: key);

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isStartingSession = false;

  // ฟังก์ชันสำหรับสร้างคาบเรียนใหม่
  Future<void> _startSession() async {
    setState(() => _isStartingSession = true);
    try {
      // เรียกใช้ Service เพื่อสร้าง Session ใหม่ใน Firebase
      final sessionId = await _firestoreService.startNewCheckinSession(
        widget.course.id,
      );
      // เมื่อสร้างสำเร็จ นำทางไปยังหน้า Live Session
      _navigateToSession(sessionId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error starting session: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isStartingSession = false);
      }
    }
  }

  // ฟังก์ชันสำหรับนำทางไปยังหน้า Live Session (ใช้ซ้ำได้)
  void _navigateToSession(String sessionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CheckInScreen(course: widget.course, sessionId: sessionId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.course.name)),
      body: Column(
        children: [
          // --- ส่วนที่ 1: ปุ่มเริ่ม Session ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isStartingSession
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _startSession,
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    label: const Text("Start New Check-in Session"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
          ),
          const Divider(thickness: 1),

          // --- ส่วนที่ 2: รายการ Session ที่ผ่านมา ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "Past Sessions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<CheckinSession>>(
              stream: _firestoreService.getCourseSessionsStream(
                widget.course.id,
              ),
              builder: (context, snapshot) {
                // ขณะกำลังโหลด
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // กรณีเกิด Error
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                // กรณีไม่มีข้อมูล
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No sessions found yet."));
                }

                final sessions = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    // จัดรูปแบบวันที่ให้อ่านง่าย
                    final formattedDate = DateFormat(
                      'dd MMM yyyy, hh:mm a',
                    ).format(session.startTime.toDate());
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const Icon(
                          Icons.history_toggle_off,
                          color: Colors.indigo,
                        ),
                        title: Text("Session on $formattedDate"),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        // ทำให้สามารถกดดูรายละเอียดของ Session เก่าได้
                        onTap: () => _navigateToSession(session.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
