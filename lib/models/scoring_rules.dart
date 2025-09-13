class ScoringRules {
  double presentScore;
  double absentScore;
  double onLeaveScore;
  double lateScore;

  ScoringRules({
    this.presentScore = 1.0,
    this.absentScore = 0.0,
    this.onLeaveScore = 0.5,
    this.lateScore = 0.75,
  });

  // --- [โค้ดใหม่] เครื่องมือแปลง Object เป็น Map ---
  Map<String, dynamic> toJson() {
    return {
      'presentScore': presentScore,
      'absentScore': absentScore,
      'onLeaveScore': onLeaveScore,
      'lateScore': lateScore,
    };
  }

  // --- [โค้ดใหม่] เครื่องมือแปลง Map กลับเป็น Object ---
  factory ScoringRules.fromJson(Map<String, dynamic> json) {
    return ScoringRules(
      presentScore: json['presentScore'] ?? 1.0,
      absentScore: json['absentScore'] ?? 0.0,
      onLeaveScore: json['onLeaveScore'] ?? 0.5,
      lateScore: json['lateScore'] ?? 0.75,
    );
  }
}
