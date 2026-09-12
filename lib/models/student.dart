import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String fullName;
  final String rollNo;
  final String enrollmentId;
  final String departmentId;
  final String sectionId;
  final int year;

  Student({
    required this.id,
    required this.fullName,
    required this.rollNo,
    required this.enrollmentId,
    required this.departmentId,
    required this.sectionId,
    required this.year,
  });

  factory Student.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Student(
      id: doc.id,
      fullName: d['fullName'] ?? '',
      rollNo: d['rollNo'] ?? '',
      enrollmentId: d['enrollmentId'] ?? '',
      departmentId: d['departmentId'] ?? '',
      sectionId: d['sectionId'] ?? '',
      year: d['year'] ?? 1,
    );
  }
}