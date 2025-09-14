import 'package:cloud_firestore/cloud_firestore.dart'; // <<<--- แก้ไขที่อยู่ตรงนี้ให้ถูกต้อง
import 'scoring_rules.dart';

class Course {
  final String id;
  final String name;
  final String professorName;
  final ScoringRules scoringRules;
  final String professorId;
  final List<String> studentUids;

  Course({
    required this.id,
    required this.name,
    required this.professorName,
    required this.scoringRules,
    required this.professorId,
    this.studentUids = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'professorName': professorName,
      'professorId': professorId,
      'scoringRules': scoringRules.toJson(),
      'studentUids': studentUids,
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
    );
  }
}
