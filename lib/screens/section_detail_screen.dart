import 'package:flutter/material.dart';
import '../models/section.dart';
import '../models/student.dart';
import '../services/student_service.dart';
import 'add_student_screen.dart';
import 'import_students_screen.dart';

class SectionDetailScreen extends StatefulWidget {
  final Section section;

  const SectionDetailScreen({super.key, required this.section});

  @override
  State<SectionDetailScreen> createState() => _SectionDetailScreenState();
}

class _SectionDetailScreenState extends State<SectionDetailScreen> {
  final _service = StudentService();
  late Future<List<Student>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getStudents(widget.section.id);
  }

  void _refresh() {
    setState(() {
      _future = _service.getStudents(widget.section.id);
    });
  }

  Future<void> _openImport() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImportStudentsScreen(section: widget.section),
      ),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Section ${widget.section.id}'),
        actions: [
          IconButton(
            tooltip: 'Import from Excel/CSV',
            icon: const Icon(Icons.upload_file),
            onPressed: _openImport,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add),
        label: const Text('Add Student'),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddStudentScreen(section: widget.section),
            ),
          );
          _refresh();
        },
      ),
      body: FutureBuilder<List<Student>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final students = snapshot.data ?? [];
          if (students.isEmpty) {
            return const Center(
              child: Text(
                'No students yet.\n'
                'Tap + to add one, or use the upload icon to import.',
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, i) {
              final s = students[i];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(s.fullName),
                subtitle:
                    Text('Roll: ${s.rollNo} • Enroll: ${s.enrollmentId}'),
              );
            },
          );
        },
      ),
    );
  }
}