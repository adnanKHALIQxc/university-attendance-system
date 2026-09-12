import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/teacher.dart';

class TeacherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _teachers => _firestore.collection('teachers');

  Future<List<Teacher>> getAllTeachers() async {
    final snap = await _teachers.where('isActive', isEqualTo: true).get();
    final list = snap.docs.map((d) => Teacher.fromFirestore(d)).toList();
    list.sort((a, b) =>
        a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
    return list;
  }

  Future<Teacher?> getTeacher(String uid) async {
    final doc = await _teachers.doc(uid).get();
    if (!doc.exists) return null;
    return Teacher.fromFirestore(doc);
  }
}