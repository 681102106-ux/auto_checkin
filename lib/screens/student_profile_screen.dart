import 'package:auto_checkin/models/student_profile.dart';
import 'package:auto_checkin/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: currentUser == null
          ? const Center(child: Text('User not found.'))
          : FutureBuilder<StudentProfile>(
              // เรียก "พ่อครัวใหญ่" ให้ไปดึงข้อมูลโปรไฟล์ของเรา
              future: FirestoreService().getStudentProfile(currentUser.uid),
              builder: (context, snapshot) {
                // ถ้ากำลังโหลด...
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // ถ้าเกิด Error...
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(child: Text('Could not load profile.'));
                }

                // ถ้าโหลดสำเร็จ!
                final profile = snapshot.data!;

                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildProfileInfoTile('Full Name', profile.fullName),
                    _buildProfileInfoTile('Student ID', profile.studentId),
                    _buildProfileInfoTile('Faculty', profile.faculty),
                    _buildProfileInfoTile('Major', profile.major),
                    _buildProfileInfoTile('Year', profile.year.toString()),
                    _buildProfileInfoTile('Phone Number', profile.phoneNumber),
                    _buildProfileInfoTile('Email', profile.email),
                  ],
                );
              },
            ),
    );
  }

  // ฟังก์ชันช่วยสร้าง UI ให้สวยงามและลดโค้ดซ้ำซ้อน
  Widget _buildProfileInfoTile(String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
