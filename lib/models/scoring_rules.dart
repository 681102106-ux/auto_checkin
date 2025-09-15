class ScoringRules {
  final double presentScore;
  final double lateScore;
  final double onLeaveScore;
  final double absentScore;

  // --- แก้ไขตามสเปก ---
  ScoringRules({
    this.presentScore = 1.0,
    this.lateScore = 0.5,
    this.onLeaveScore = 0.25,
    this.absentScore = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'presentScore': presentScore,
      'lateScore': lateScore,
      'onLeaveScore': onLeaveScore,
      'absentScore': absentScore,
    };
  }
}
