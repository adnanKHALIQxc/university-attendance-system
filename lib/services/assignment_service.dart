import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/teaching_assignment.dart';

class AssignmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _assignments =>
      _firestore.collection('teachingAssignments');

  Future<void> createAssignment({
    required String teacherId,
    required String teacherName,
    required String subjectId,
    required String subjectName,
    required String sectionId,
    required String academicYear,
    required int semester,
  }) async {
    // Reject duplicates: same teacher + same subject + same section
    final dup = await _assignments
        .where('teacherId', isEqualTo: teacherId)
        .where('subjectId', isEqualTo: subjectId)
        .where('sectionId', isEqualTo: sectionId)
        .limit(1)
        .get();

    if (dup.docs.isNotEmpty) {
      throw Exception(
        'This teacher is already assigned to teach '
        '$subjectName in $sectionId.',
      );
    }

    await _assignments.add({
      'teacherId': teacherId,
      'teacherName': teacherName,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'sectionId': sectionId,
      'academicYear': academicYear,
      'semester': semester,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteAssignment(String assignmentId) async {
    await _assignments.doc(assignmentId).delete();
  }

  /// All assignments in a section (admin section detail).
  Future<List<TeachingAssignment>> getAssignmentsForSection(
    String sectionId,
  ) async {
    final snap = await _assignments
        .where('sectionId', isEqualTo: sectionId)
        .get();
    final list =
        snap.docs.map((d) => TeachingAssignment.fromFirestore(d)).toList();
    list.sort((a, b) => a.subjectId.compareTo(b.subjectId));
    return list;
  }

  /// All assignments for a teacher (teacher dashboard).
  Future<List<TeachingAssignment>> getAssignmentsForTeacher(
    String teacherId,
  ) async {
    final snap = await _assignments
        .where('teacherId', isEqualTo: teacherId)
        .get();
    final list =
        snap.docs.map((d) => TeachingAssignment.fromFirestore(d)).toList();
    list.sort((a, b) {
      final c = a.sectionId.compareTo(b.sectionId);
      return c != 0 ? c : a.subjectId.compareTo(b.subjectId);
    });
    return list;
  }
}