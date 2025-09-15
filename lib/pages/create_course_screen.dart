import 'package:auto_checkin/models/scoring_rules.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({Key? key}) : super(key: key);

  @override
  _CreateCourseScreenState createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courseNameController = TextEditingController();
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _createCourse() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final user = _auth.currentUser;
      if (user == null) return;

      try {
        // --- แก้ไขตามสเปก ---
        final defaultScoringRules = ScoringRules(
          presentScore: 1,
          lateScore: 0.75,
          onLeaveScore: 0.5,
          absentScore: 0,
        );

        await _firestore.collection('courses').add({
          'name': _courseNameController.text,
          'professorId': user.uid,
          'professorName': user.displayName ?? user.email,
          'createdAt': FieldValue.serverTimestamp(),
          'scoringRules': defaultScoringRules.toMap(),
          'studentUids': [],
        });
        Navigator.of(context).pop();
      } catch (e) {
        // ... error handling ...
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Course')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _courseNameController,
                decoration: const InputDecoration(labelText: 'Course Name'),
                validator: (v) => v!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _createCourse,
                      child: const Text('Create Course'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
