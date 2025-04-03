import 'package:flutter/material.dart';
import 'package:frontend/screens/teacher/question_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/question.dart';
import '../../controllers/question_controller.dart';

class QuestionListScreen extends StatelessWidget {
  final String quizCategory;
  QuestionListScreen({super.key, required this.quizCategory});
  final QuestionController questionController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Questions in $quizCategory"),
      ),
      body: FutureBuilder<List<String>>(
        future: _loadQuestions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No questions found"));
          }

          final questions = snapshot.data!.map((jsonString) {
            final Map<String, dynamic> data = jsonDecode(jsonString);
            return Question(
              category: data['category'],
              id: data['id'],
              questions: data['questions'],
              options: List<String>.from(data['options']),
              answer: data['answer'],
            );
          }).toList();

          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Question ${index + 1}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(question.questions),
                      const SizedBox(height: 8),
                      ...question.options.asMap().entries.map((entry) {
                        final isCorrect = entry.key == question.answer;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Text("${entry.key + 1}. "),
                              Expanded(child: Text(entry.value)),
                              if (isCorrect)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 16,
                                ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _editQuestion(context, question),
                            icon: const Icon(Icons.edit),
                            label: const Text("Edit"),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () => _deleteQuestion(question.id),
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text("Delete",
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<String>> _loadQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('questions') ?? [];
  }

  void _editQuestion(BuildContext context, Question question) {
    // TODO: Implement edit functionality
    Get.snackbar("Edit", "Edit functionality coming soon");
  }

  Future<void> _deleteQuestion(int questionId) async {
    final prefs = await SharedPreferences.getInstance();
    final questions = prefs.getStringList('questions') ?? [];

    questions.removeWhere((jsonString) {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      return data['id'] == questionId;
    });

    await prefs.setStringList('questions', questions);
    Get.snackbar("Deleted", "Question deleted successfully");
    Get.off(() => QuestionListScreen(quizCategory: quizCategory));
  }
}
