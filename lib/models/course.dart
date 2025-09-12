import 'scoring_rules.dart'; // Import พิมพ์เขียวใหม่เข้ามา

class Course {
  final String id;
  final String name;
  final String professorName;
  final ScoringRules scoringRules; // เพิ่ม "กล่องเก็บกฎกติกา" เข้ามา!

  Course({
    required this.id,
    required this.name,
    required this.professorName,
    required this.scoringRules, // ทำให้ต้องมีกฎเสมอ
  });
}
