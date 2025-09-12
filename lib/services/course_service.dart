import '../models/course.dart';
import '../models/scoring_rules.dart';

class CourseService {
  // นี่คือ "คลังวัตถุดิบ" ของเรา (ข้อมูลจำลอง)
  // ตอนนี้มันถูกย้ายมาอยู่ในครัวเรียบร้อยแล้ว
  final List<Course> _courses = [
    Course(
      id: 'CS101',
      name: 'Introduction to Computer Science',
      professorName: 'อ.นราศักดิ์',
      scoringRules: ScoringRules(),
    ),
    Course(
      id: 'MA101',
      name: 'Calculus I',
      professorName: 'อ.สมศรี',
      scoringRules: ScoringRules(presentScore: 2.0, lateScore: 1.0),
    ),
  ];

  // นี่คือเมนูที่ "พ่อครัว" เตรียมไว้ให้ "พนักงานเสิร์ฟ" เรียกใช้
  // ฟังก์ชันสำหรับดึงรายวิชาทั้งหมด
  List<Course> getCourses() {
    // ในอนาคต โค้ดส่วนนี้จะเปลี่ยนไปเป็นการดึงข้อมูลจาก Database จริงๆ
    return _courses;
  }

  // ฟังก์ชันสำหรับเพิ่มรายวิชาใหม่
  void addCourse(Course course) {
    _courses.add(course);
  }

  // ฟังก์ชันสำหรับแก้ไขรายวิชา
  void updateCourse(Course updatedCourse) {
    final index = _courses.indexWhere((c) => c.id == updatedCourse.id);
    if (index != -1) {
      _courses[index] = updatedCourse;
    }
  }
}
