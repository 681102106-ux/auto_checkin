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
}
