import 'package:cloud_firestore/cloud_firestore.dart';

class Department {
  final String id;          // short code like "CS"
  final String name;        // full name like "Computer Science"
  final bool isActive;
  final DateTime? createdAt;

  Department({
    required this.id,
    required this.name,
    this.isActive = true,
    this.createdAt,
  });

  factory Department.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Department(
      id: doc.id,
      name: data['name'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}