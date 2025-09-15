import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfessorStudentsScreen extends StatefulWidget {
  const ProfessorStudentsScreen({Key? key}) : super(key: key);

  @override
  _ProfessorStudentsScreenState createState() =>
      _ProfessorStudentsScreenState();
}

class _ProfessorStudentsScreenState extends State<ProfessorStudentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _years = ['1', '2', '3', '4', 'Other'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _years.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _getStudentsByYear(String year) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.error("User not logged in");
    }
    return FirebaseFirestore.instance
        .collection('professors')
        .doc(user.uid)
        .collection('students')
        .where('year', isEqualTo: year)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Student Roster'),
        backgroundColor: Colors.deepPurple,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _years.map((year) => Tab(text: 'Year $year')).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _years.map((year) {
          return StreamBuilder<QuerySnapshot>(
            stream: _getStudentsByYear(year),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No students found for Year $year.'));
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final students = snapshot.data!.docs;

              return ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final studentData =
                      students[index].data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple.shade100,
                        child: Text(studentData['name']?[0] ?? 'N/A'),
                      ),
                      title: Text(studentData['name'] ?? 'Unknown Name'),
                      subtitle: Text(
                        'ID: ${studentData['student_id_number'] ?? 'N/A'}',
                      ),
                    ),
                  );
                },
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
