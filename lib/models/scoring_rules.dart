class ScoringRules {
  final double presentScore;
  final double lateScore;
  final double onLeaveScore;
  final double absentScore;

  // แก้ไข Constructor ให้รับค่าเริ่มต้นได้
  ScoringRules({
    this.presentScore = 1.0,
    this.lateScore = 0.5,
    this.onLeaveScore = 0.25,
    this.absentScore = 0.0,
  });

  // ฟังก์ชันสำหรับแปลงข้อมูลเป็น Map เพื่อบันทึกลง Firestore
  Map<String, dynamic> toMap() {
    return {
      'presentScore': presentScore,
      'lateScore': lateScore,
      'onLeaveScore': onLeaveScore,
      'absentScore': absentScore,
    };
  }
}
