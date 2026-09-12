import 'package:cloud_firestore/cloud_firestore.dart';

class Section {
  final String id;
  final String departmentId;
  final int year;
  final String name;
  final String academicYear;
  final int totalStudents;
  final bool isActive;

  Section({
    required this.id,
    required this.departmentId,
    required this.year,
    required this.name,
    required this.academicYear,
    this.totalStudents = 0,
    this.isActive = true,
  });

  factory Section.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Section(
      id: doc.id,
      departmentId: d['departmentId'] ?? '',
      year: d['year'] ?? 1,
      name: d['name'] ?? '',
      academicYear: d['academicYear'] ?? '',
      totalStudents: d['totalStudents'] ?? 0,
      isActive: d['isActive'] ?? true,
    );
  }
}