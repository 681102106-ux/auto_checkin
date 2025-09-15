import 'package:cloud_firestore/cloud_firestore.dart';
import 'scoring_rules.dart';

class Course {
  final String id;
  final String name;
  final String professorName;
  final ScoringRules scoringRules;
  final String professorId;
  final List<String> studentUids; // นักเรียนที่อนุมัติแล้ว
  final List<String> pendingStudents; // <<<--- [ใหม่!] นักเรียนที่รออนุมัติ
  final String joinCode;
  final bool joinCodeEnabled; // <<<--- [ใหม่!] สวิตช์เปิด/ปิดรหัสเชิญ

  Course({
    required this.id,
    required this.name,
    required this.professorName,
    required this.scoringRules,
    required this.professorId,
    this.studentUids = const [],
    this.pendingStudents = const [], // <<<--- [ใหม่!]
    required this.joinCode,
    this.joinCodeEnabled = true, // <<<--- [ใหม่!] ค่าเริ่มต้นคือเปิดใช้งาน
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'professorName': professorName,
      'professorId': professorId,
      'scoringRules': scoringRules.toJson(),
      'studentUids': studentUids,
      'pendingStudents': pendingStudents, // <<<--- [ใหม่!]
      'joinCode': joinCode,
      'joinCodeEnabled': joinCodeEnabled, // <<<--- [ใหม่!]
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
      studentUids: List<String>.from(data['studentUids'] ?? []),
      pendingStudents: List<String>.from(
        data['pendingStudents'] ?? [],
      ), // <<<--- [ใหม่!]
      joinCode: data['joinCode'] ?? '',
      joinCodeEnabled: data['joinCodeEnabled'] ?? true, // <<<--- [ใหม่!]
    );
  }
}
