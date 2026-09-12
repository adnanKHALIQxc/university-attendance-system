import 'package:cloud_firestore/cloud_firestore.dart';

class Subject {
  final String id;         // e.g., "CS301"
  final String name;       // e.g., "Data Structures"
  final int creditHours;
  final String departmentId;
  final int year;
  final int semester;
  final bool isActive;

  Subject({
    required this.id,
    required this.name,
    required this.creditHours,
    required this.departmentId,
    required this.year,
    required this.semester,
    this.isActive = true,
  });

  factory Subject.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Subject(
      id: doc.id,
      name: d['name'] ?? '',
      creditHours: d['creditHours'] ?? 0,
      departmentId: d['departmentId'] ?? '',
      year: d['year'] ?? 1,
      semester: d['semester'] ?? 1,
      isActive: d['isActive'] ?? true,
    );
  }
}