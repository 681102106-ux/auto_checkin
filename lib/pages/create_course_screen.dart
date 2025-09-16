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
  final _professorNameController = TextEditingController();

  // Controllers for scoring rules
  final _presentScoreController = TextEditingController(text: '1.0');
  final _lateScoreController = TextEditingController(text: '0.75');
  final _onLeaveScoreController = TextEditingController(text: '0.5');
  final _absentScoreController = TextEditingController(text: '0.0');

  bool _isJoinCodeEnabled = true;
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Set initial professor name
    _professorNameController.text =
        _auth.currentUser?.displayName ??
        _auth.currentUser?.email ??
        'Professor';
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _professorNameController.dispose();
    _presentScoreController.dispose();
    _lateScoreController.dispose();
    _onLeaveScoreController.dispose();
    _absentScoreController.dispose();
    super.dispose();
  }

  Future<void> _saveCourse() async {
    // 1. ตรวจสอบความถูกต้องของฟอร์ม
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final user = _auth.currentUser;
      if (user == null) return;

      try {
        // 2. สร้าง object กฎการให้คะแนนจากฟอร์ม
        final scoringRules = ScoringRules(
          presentScore: double.tryParse(_presentScoreController.text) ?? 1.0,
          lateScore: double.tryParse(_lateScoreController.text) ?? 0.75,
          onLeaveScore: double.tryParse(_onLeaveScoreController.text) ?? 0.5,
          absentScore: double.tryParse(_absentScoreController.text) ?? 0.0,
        );

        // 3. บันทึกข้อมูลทั้งหมดลง Firestore
        await _firestore.collection('courses').add({
          'name': _courseNameController.text,
          'professorId': user.uid,
          'professorName': _professorNameController.text,
          'isInviteEnabled':
              _isJoinCodeEnabled, // ใช้ชื่อ isInviteEnabled ตามโมเดล
          'createdAt': FieldValue.serverTimestamp(),
          'scoringRules': scoringRules.toMap(),
          'studentUids': [],
        });

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Course created successfully!')),
          );
        }
      } catch (e) {
        // Handle error
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Course')),
      body: Form(
        key: _formKey,
        child: ListView(
          // ใช้ ListView เพื่อป้องกัน overflow
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _courseNameController,
              decoration: const InputDecoration(
                labelText: 'Course Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v!.isEmpty ? 'Please enter a course name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _professorNameController,
              decoration: const InputDecoration(
                labelText: 'Professor Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v!.isEmpty ? 'Please enter a professor name' : null,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Join via QR Code'),
              value: _isJoinCodeEnabled,
              onChanged: (value) => setState(() => _isJoinCodeEnabled = value),
            ),
            const Divider(height: 32),
            const Text(
              "Scoring Rules",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _buildScoreTextField(_presentScoreController, "Present Score"),
            _buildScoreTextField(_lateScoreController, "Late Score"),
            _buildScoreTextField(_onLeaveScoreController, "On Leave Score"),
            _buildScoreTextField(_absentScoreController, "Absent Score"),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Save Course'),
                    onPressed: _saveCourse,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Please enter a value';
          if (double.tryParse(v) == null) return 'Please enter a valid number';
          return null;
        },
      ),
    );
  }
}
