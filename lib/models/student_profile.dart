import 'package:cloud_firestore/cloud_firestore.dart';

class StudentProfile {
  final String uid;
  final String email;
  final String studentId;
  final String fullName;
  final String faculty;
  final String major;
  final int year;
  final String phoneNumber;

  StudentProfile({
    required this.uid,
    required this.email,
    required this.studentId,
    required this.fullName,
    required this.faculty,
    required this.major,
    required this.year,
    required this.phoneNumber,
  });

  factory StudentProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return StudentProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      studentId: data['studentId'] ?? '',
      fullName: data['fullName'] ?? '',
      faculty: data['faculty'] ?? '',
      major: data['major'] ?? '',
      year: data['year'] ?? 0,
      phoneNumber: data['phoneNumber'] ?? '',
    );
  }
}
