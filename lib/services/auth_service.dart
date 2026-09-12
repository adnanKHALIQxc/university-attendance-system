import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  /// Returns a Result with either role or error message.
  Future<({String? role, String? error})> login(
    String id,
    String password,
  ) async {
    try {
      final email = '$id@uniattend.local';

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

            final uid = credential.user!.uid;

      // Check teacher collection FIRST — rules allow any signed-in user
      // to read this collection, so it works for teachers AND admins.
      final teacherDoc =
          await _firestore.collection('teachers').doc(uid).get();
      if (teacherDoc.exists) {
        final role = (teacherDoc.data()?['role'] as String?) ?? 'teacher';
        return (role: role, error: null);
      }

      // Then check admin collection — only reachable if teacher check failed
      final adminDoc = await _firestore.collection('admins').doc(uid).get();
      if (adminDoc.exists) {
        return (role: 'admin', error: null);
      }

      // Auth user exists but no Firestore record
      await _auth.signOut();
      return (
        role: null,
        error: 'Signed in, but no profile found in Firestore. '
            'Check that the teacher doc ID matches the Auth UID exactly.',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} — ${e.message}');
      return (role: null, error: 'Auth error [${e.code}]: ${e.message}');
    } catch (e) {
      debugPrint('Login error: $e');
      return (role: null, error: 'Unknown: $e');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<({String id, String password})> createTeacher({
    required String fullName,
    required String contactEmail,
  }) async {
    FirebaseApp secondaryApp;
    try {
      secondaryApp = Firebase.app('SecondaryApp');
    } on FirebaseException {
      secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

    final teacherId = (100000 + Random().nextInt(900000)).toString();
    final generatedEmail = '$teacherId@uniattend.local';
    final generatedPassword = _generatePassword();

    try {
      final cred = await secondaryAuth.createUserWithEmailAndPassword(
        email: generatedEmail,
        password: generatedPassword,
      );
      final uid = cred.user!.uid;
      await secondaryAuth.signOut();

      await _firestore.collection('teachers').doc(uid).set({
        'id': teacherId,
        'fullName': fullName,
        'contactEmail': contactEmail,
        'authEmail': generatedEmail,
        'role': 'teacher',
        'isActive': true,
        'hasChangedPassword': false,
        'assignedSectionIds': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Created teacher: id=$teacherId uid=$uid');
      return (id: teacherId, password: generatedPassword);
    } catch (e) {
      debugPrint('Create teacher error: $e');
      rethrow;
    }
  }

  String _generatePassword() {
    const chars =
        'abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random.secure();
    return List.generate(8, (_) => chars[rnd.nextInt(chars.length)]).join();
  }
}