import 'package:cloud_firestore/cloud_firestore.dart';
import 'scoring_rules.dart';

class Course {
  final String id;
  final String name;
  final String professorName;
  final ScoringRules scoringRules;
  final String professorId; // <<<--- เพิ่ม: ID ของอาจารย์เจ้าของคลาส

  Course({
    required this.id,
    required this.name,
    required this.professorName,
    required this.scoringRules,
    required this.professorId, // <<<--- เพิ่ม
  });

  // --- [โค้ดใหม่] เครื่องมือแปลง Object เป็น Map เพื่อส่งให้ Firestore ---
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'professorName': professorName,
      'professorId': professorId,
      'scoringRules': scoringRules.toJson(),
    };
  }

  // --- [โค้ดใหม่] เครื่องมือแปลงข้อมูลจาก Firestore กลับเป็น Object ---
  factory Course.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Course(
      id: doc.id,
      name: data['name'] ?? '',
      professorName: data['professorName'] ?? '',
      professorId: data['professorId'] ?? '',
      scoringRules: ScoringRules.fromJson(data['scoringRules'] ?? {}),
    );
  }
}
