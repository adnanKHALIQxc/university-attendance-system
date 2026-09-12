import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns role ('admin' or 'teacher') if login succeeds, else null.
  Future<String?> login(String id, String password) async {
    try {
      final email = '$id@uniattend.local';

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // Check admin collection first
      final adminDoc = await _firestore.collection('admins').doc(uid).get();
      if (adminDoc.exists) return 'admin';

      // Check teacher collection
      final teacherDoc =
          await _firestore.collection('teachers').doc(uid).get();
      if (teacherDoc.exists) return teacherDoc.data()?['role'] ?? 'teacher';

      // Auth user exists but no Firestore record — reject
      await _auth.signOut();
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Creates a teacher account with an auto-generated 6-digit ID + password.
  /// Returns a record containing the generated credentials.
  Future<({String id, String password})> createTeacher({
    required String fullName,
    required String contactEmail,
  }) async {
    // 1. Get or create secondary Firebase app
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

    // 2. Generate credentials
    final teacherId = (100000 + Random().nextInt(900000)).toString();
    final generatedEmail = '$teacherId@uniattend.local';
    final generatedPassword = _generatePassword();

    try {
      // 3. Create Firebase Auth user via secondary app
      final cred = await secondaryAuth.createUserWithEmailAndPassword(
        email: generatedEmail,
        password: generatedPassword,
      );
      final uid = cred.user!.uid;
      await secondaryAuth.signOut();

      // 4. Write Firestore doc from PRIMARY app (admin's session)
      await _firestore.collection('teachers').doc(uid).set({
        'id': teacherId,
        'fullName': fullName,
        'contactEmail': contactEmail,
        'authEmail': generatedEmail,
        'role': 'teacher',
        'isActive': true,
        'hasChangedPassword': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return (id: teacherId, password: generatedPassword);
    } catch (e) {
      print('Create teacher error: $e');
      rethrow;
    }
  }

  String _generatePassword() {
    // 8-char random password: letters + digits
    const chars =
        'abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random.secure();
    return List.generate(8, (_) => chars[rnd.nextInt(chars.length)]).join();
  }
}