import 'package:cloud_firestore/cloud_firestore.dart';

class CheckinSession {
  final String id;
  final String courseId;
  final Timestamp startTime;
  final bool isActive;

  CheckinSession({
    required this.id,
    required this.courseId,
    required this.startTime,
    required this.isActive,
  });

  factory CheckinSession.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CheckinSession(
      id: doc.id,
      courseId: data['courseId'] ?? '',
      startTime: data['startTime'] ?? Timestamp.now(),
      isActive: data['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'courseId': courseId, 'startTime': startTime, 'isActive': isActive};
  }
}
