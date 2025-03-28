import 'package:flutter/material.dart';

class MockExamView extends StatefulWidget {
  const MockExamView({Key? key}) : super(key: key);

  @override
  State<MockExamView> createState() => _MockExamViewState();
}

class _MockExamViewState extends State<MockExamView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mock Exams",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const Center(
        child: Text('Mock Exam View - Coming Soon'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add mock exam functionality
        },
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add),
      ),
    );
  }
}
