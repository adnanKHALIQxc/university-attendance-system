import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/section.dart';

class SectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _sections => _firestore.collection('sections');

  String buildId(String deptId, int year, String name) {
    return '$deptId-$year${name.toUpperCase()}';
  }

  Future<void> createSection({
    required String departmentId,
    required int year,
    required String name,
    required String academicYear,
  }) async {
    final sectionId = buildId(departmentId, year, name);
    final docRef = _sections.doc(sectionId);

    final exists = (await docRef.get()).exists;
    if (exists) {
      throw Exception('Section "$sectionId" already exists');
    }

    await docRef.set({
      'id': sectionId,
      'departmentId': departmentId,
      'year': year,
      'name': name.toUpperCase(),
      'academicYear': academicYear,
      'totalStudents': 0,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Section>> getSections(String departmentId, int year) async {
    final snap = await _sections
        .where('departmentId', isEqualTo: departmentId)
        .where('year', isEqualTo: year)
        .where('isActive', isEqualTo: true)
        .get();

    final list = snap.docs.map((d) => Section.fromFirestore(d)).toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }
}