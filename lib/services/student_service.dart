import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class StudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _students => _firestore.collection('students');

  Future<void> addStudent({
    required String fullName,
    required String rollNo,
    required String enrollmentId,
    required String departmentId,
    required String sectionId,
    required int year,
  }) async {
    await _students.add({
      'fullName': fullName.trim(),
      'rollNo': rollNo.trim(),
      'enrollmentId': enrollmentId.trim(),
      'departmentId': departmentId,
      'sectionId': sectionId,
      'year': year,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('sections').doc(sectionId).update({
      'totalStudents': FieldValue.increment(1),
    });
  }

  Future<List<Student>> getStudents(String sectionId) async {
    final snap = await _students
        .where('sectionId', isEqualTo: sectionId)
        .where('isActive', isEqualTo: true)
        .get();

    final list = snap.docs.map((d) => Student.fromFirestore(d)).toList();
    list.sort((a, b) => a.rollNo.compareTo(b.rollNo));
    return list;
  }
}