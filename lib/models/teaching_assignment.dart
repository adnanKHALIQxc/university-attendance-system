import 'package:cloud_firestore/cloud_firestore.dart';

class TeachingAssignment {
  final String id;
  final String teacherId;   // uid
  final String teacherName; // denormalized for display
  final String subjectId;
  final String subjectName; // denormalized for display
  final String sectionId;
  final String academicYear;
  final int semester;

  TeachingAssignment({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.subjectId,
    required this.subjectName,
    required this.sectionId,
    required this.academicYear,
    required this.semester,
  });

  factory TeachingAssignment.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return TeachingAssignment(
      id: doc.id,
      teacherId: d['teacherId'] ?? '',
      teacherName: d['teacherName'] ?? '',
      subjectId: d['subjectId'] ?? '',
      subjectName: d['subjectName'] ?? '',
      sectionId: d['sectionId'] ?? '',
      academicYear: d['academicYear'] ?? '',
      semester: d['semester'] ?? 1,
    );
  }
}