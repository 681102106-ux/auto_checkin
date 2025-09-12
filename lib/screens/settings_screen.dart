import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final Map<String, double> initialScores;
  final Function(Map<String, double>) onScoresUpdated;

  const SettingsScreen({
    super.key,
    required this.initialScores,
    required this.onScoresUpdated,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Map<String, double> _scores;

  @override
  void initState() {
    super.initState();
    _scores = Map<String, double>.from(widget.initialScores);
  }

  Future<void> _showEditScoreDialog(
    String title,
    double currentValue,
    Function(double) onSave,
  ) async {
    final TextEditingController scoreController = TextEditingController(
      text: currentValue.toString(),
    );

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('แก้ไขคะแนนสำหรับ "$title"'),
          content: TextField(
            controller: scoreController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'คะแนนใหม่',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('บันทึก'),
              onPressed: () {
                final double? newScore = double.tryParse(scoreController.text);
                if (newScore != null) {
                  onSave(newScore);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              widget.onScoresUpdated(_scores);
              Navigator.of(context).pop();
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
            ),
            title: const Text('มาเรียน'),
            trailing: Text('${_scores['present'] ?? 1.0} คะแนน'),
            onTap: () {
              _showEditScoreDialog('มาเรียน', _scores['present'] ?? 1.0, (
                newScore,
              ) {
                setState(() {
                  _scores['present'] = newScore;
                });
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.cancel_outlined, color: Colors.red),
            title: const Text('ขาด'),
            trailing: Text('${_scores['absent'] ?? 0.0} คะแนน'),
            onTap: () {
              _showEditScoreDialog('ขาด', _scores['absent'] ?? 0.0, (newScore) {
                setState(() {
                  _scores['absent'] = newScore;
                });
              });
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.description_outlined,
              color: Colors.orange,
            ),
            title: const Text('ลา'),
            trailing: Text('${_scores['onLeave'] ?? 0.5} คะแนน'),
            onTap: () {
              _showEditScoreDialog('ลา', _scores['onLeave'] ?? 0.5, (newScore) {
                setState(() {
                  _scores['onLeave'] = newScore;
                });
              });
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.watch_later_outlined,
              color: Colors.blueGrey,
            ),
            title: const Text('มาสาย'),
            trailing: Text('${_scores['late'] ?? 0.75} คะแนน'),
            onTap: () {
              _showEditScoreDialog('มาสาย', _scores['late'] ?? 0.75, (
                newScore,
              ) {
                setState(() {
                  _scores['late'] = newScore;
                });
              });
            },
          ),
        ],
      ),
    );
  }
}
