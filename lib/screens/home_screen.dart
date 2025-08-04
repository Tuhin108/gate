import 'package:flutter/material.dart';
import 'package:gate_survey_app/models/survey_data.dart';
import 'package:gate_survey_app/screens/sliding_gate_survey_screen.dart';
import 'package:gate_survey_app/screens/swing_gate_survey_screen.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<GateSurveyData> _completedSurveys = [];

  void _addSurvey(GateSurveyData survey) {
    setState(() {
      _completedSurveys.add(survey);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${survey.type.name} Gate Survey Saved!')),
    );
  }

  Future<void> _exportSurveysToCsv() async {
    if (_completedSurveys.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No surveys to export!')),
      );
      return;
    }

    List<List<dynamic>> rows = [];

    // Determine all possible headers from both types of surveys
    Set<String> allHeaders = {};
    for (var survey in _completedSurveys) {
      allHeaders.addAll(survey.toMap().keys);
    }
    rows.add(allHeaders.toList()); // Add headers as the first row

    // Add data rows
    for (var survey in _completedSurveys) {
      List<dynamic> row = [];
      Map<String, dynamic> surveyMap = survey.toMap();
      for (var header in allHeaders) {
        row.add(surveyMap[header] ?? ''); // Add value or empty string if not present
      }
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/gate_surveys.csv';
    final file = File(path);
    await file.writeAsString(csv);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Surveys exported to $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 40,
            ),
            const SizedBox(width: 10),
            const Text('Gate Survey App'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export Surveys to CSV',
            onPressed: _exportSurveysToCsv,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Start a New Survey',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.teal),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Sliding Gate Survey'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => SlidingGateSurveyScreen(onSave: _addSurvey),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.compare_arrows),
                      label: const Text('Swing Gate Survey'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => SwingGateSurveyScreen(onSave: _addSurvey),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Completed Surveys (${_completedSurveys.length})',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _completedSurveys.isEmpty
                  ? Center(
                      child: Text(
                        'No surveys completed yet. Start a new one!',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _completedSurveys.length,
                      itemBuilder: (ctx, index) {
                        final survey = _completedSurveys[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 2,
                          child: ListTile(
                            leading: Icon(
                              survey.type == GateType.sliding ? Icons.arrow_right_alt : Icons.compare_arrows,
                              color: Colors.teal,
                            ),
                            title: Text('${survey.type.name.toUpperCase()} Gate Survey #${index + 1}'),
                            subtitle: Text('Clear Opening: ${survey.clearOpening}m, Height: ${survey.heightRequired}m'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              // Optionally, navigate to a detail screen for the survey
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Recommendation: ${survey.toMap()['Recommendation']}')),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
