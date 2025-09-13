class StudentProfile {
  final String uid;
  final String email;
  final String studentId;
  final String fullName;
  final String faculty; // คณะ
  final String major; // สาขา
  final int year; // ชั้นปี
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
}
