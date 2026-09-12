import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/department.dart';

class DepartmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _departments => _firestore.collection('departments');

  Future<void> createDepartment({
    required String id,
    required String name,
  }) async {
    final upperId = id.trim().toUpperCase();
    final docRef = _departments.doc(upperId);

    final exists = (await docRef.get()).exists;
    if (exists) {
      throw Exception('Department "$upperId" already exists');
    }

    await docRef.set({
      'id': upperId,
      'name': name.trim(),
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Department>> getAllDepartments() async {
    final snapshot = await _departments
        .where('isActive', isEqualTo: true)
        .get();

    final list =
        snapshot.docs.map((d) => Department.fromFirestore(d)).toList();
    list.sort((a, b) => a.id.compareTo(b.id));
    return list;
  }
}