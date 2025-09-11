import 'package:flutter/material.dart';
import '../models/course.dart'; // Import พิมพ์เขียวเข้ามาด้วย

class CheckInScreen extends StatelessWidget {
  // 1. สร้าง "ช่องรับ" ข้อมูลวิชาจากหน้า Home
  final Course course;

  const CheckInScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 2. แสดงชื่อวิชาที่ได้รับมาบน AppBar
        title: Text('Check-in: ${course.name}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text('Student list will be here.')),
    );
  }
}
