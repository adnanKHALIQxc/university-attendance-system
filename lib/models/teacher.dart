import 'package:cloud_firestore/cloud_firestore.dart';

class Teacher {
  final String uid;
  final String id;
  final String fullName;
  final String contactEmail;
  final String role;
  final bool isActive;

  Teacher({
    required this.uid,
    required this.id,
    required this.fullName,
    required this.contactEmail,
    required this.role,
    required this.isActive,
  });

  factory Teacher.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Teacher(
      uid: doc.id,
      id: d['id'] ?? '',
      fullName: d['fullName'] ?? '',
      contactEmail: d['contactEmail'] ?? '',
      role: d['role'] ?? 'teacher',
      isActive: d['isActive'] ?? true,
    );
  }
}