import 'package.cloud_firestore/cloud_firestore.dart';
import 'scoring_rules.dart';

class Course {
  final String id;
  final String name;
  final String professorName;
  final ScoringRules scoringRules;
  final String professorId;
  final List<String>
  studentUids; // <<<--- [เพิ่ม!] สมุดรายชื่อนักเรียน (เก็บ UID)

  Course({
    required this.id,
    required this.name,
    required this.professorName,
    required this.scoringRules,
    required this.professorId,
    this.studentUids = const [], // <<<--- [เพิ่ม!] ค่าเริ่มต้นคือลิสต์ว่าง
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'professorName': professorName,
      'professorId': professorId,
      'scoringRules': scoringRules.toJson(),
      'studentUids': studentUids, // <<<--- [เพิ่ม!]
    };
  }

  factory Course.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Course(
      id: doc.id,
      name: data['name'] ?? '',
      professorName: data['professorName'] ?? '',
      professorId: data['professorId'] ?? '',
      scoringRules: ScoringRules.fromJson(data['scoringRules'] ?? {}),
      // แปลงข้อมูลจาก Firestore ให้เป็น List<String>
      studentUids: List<String>.from(
        data['studentUids'] ?? [],
      ), // <<<--- [เพิ่ม!]
    );
  }
}
