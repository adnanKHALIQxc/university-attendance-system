import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subject.dart';

class SubjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _subjects => _firestore.collection('subjects');

  Future<void> createSubject({
    required String id,
    required String name,
    required int creditHours,
    required String departmentId,
    required int year,
    required int semester,
  }) async {
    final upperId = id.trim().toUpperCase();
    final docRef = _subjects.doc(upperId);

    if ((await docRef.get()).exists) {
      throw Exception('Subject "$upperId" already exists');
    }

    await docRef.set({
      'id': upperId,
      'name': name.trim(),
      'creditHours': creditHours,
      'departmentId': departmentId,
      'year': year,
      'semester': semester,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// All active subjects (for admin management screen).
  Future<List<Subject>> getAllSubjects() async {
    final snap =
        await _subjects.where('isActive', isEqualTo: true).get();
    final list = snap.docs.map((d) => Subject.fromFirestore(d)).toList();
    list.sort((a, b) => a.id.compareTo(b.id));
    return list;
  }

  /// Subjects for a specific department + year (used in assign flow).
  Future<List<Subject>> getSubjectsFor({
    required String departmentId,
    required int year,
  }) async {
    final snap = await _subjects
        .where('departmentId', isEqualTo: departmentId)
        .where('year', isEqualTo: year)
        .where('isActive', isEqualTo: true)
        .get();

    final list = snap.docs.map((d) => Subject.fromFirestore(d)).toList();
    list.sort((a, b) => a.id.compareTo(b.id));
    return list;
  }
}