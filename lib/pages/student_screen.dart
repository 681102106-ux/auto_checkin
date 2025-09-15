import 'dart:convert';

import 'package:auto_checkin/pages/scan_qr_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  // ... (โค้ดเดิมทั้งหมดของ StudentScreen) ...
  // ผมจะคัดลอกมาให้ทั้งหมดด้านล่าง และแก้ส่วนที่ผิดให้ครับ

  final student = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;
  Map<String, dynamic>? studentData;
  Map<String, dynamic>? studentYear;

  @override
  void initState() {
    super.initState();
  }

  getStudentData() async {
    await db
        .collection('students')
        .doc(student!.uid)
        .get()
        .then((value) => studentData = value.data());
    return studentData;
  }

  getStudentYear() async {
    await db
        .collection('students')
        .doc(student!.uid)
        .get()
        .then((value) => studentData = value.data());
    return studentData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getStudentData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Student'),
              actions: [
                IconButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
            body: Center(
              child: Column(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                            'https://picsum.photos/200',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          studentData!['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "ID : ${studentData!['student_id']}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'My Courses',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: StreamBuilder(
                      stream: db
                          .collection('enrollments')
                          .where('student_id', isEqualTo: student!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              return Card(
                                child: ListTile(
                                  title: Text(
                                    snapshot.data!.docs[index]['course_name'],
                                  ),
                                  subtitle: Text(
                                    snapshot
                                        .data!
                                        .docs[index]['course_description'],
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // แก้ไขจาก QrScannerScreen() -> ScanQRScreen()
                    builder: (context) => const ScanQRScreen(),
                  ),
                );
              },
              child: const Icon(Icons.qr_code_scanner),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
