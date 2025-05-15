import 'mcq_question.dart';

class QuestionBank {
  final String id;
  final String title;

  final List<MCQQuestion> questions;
  final DateTime? createdDate;

  QuestionBank(
      {required this.id,
      required this.title,
      required this.questions,
      this.createdDate});

  Map<String, dynamic> toJson() {
    return {
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }

  factory QuestionBank.fromJson(Map<String, dynamic> json) {
    return QuestionBank(
        id: json['id']?.toString() ?? '',
        title: json['title'],
        questions: (json['questions'] as List?)
                ?.map((q) => MCQQuestion.fromJson(q as Map<String, dynamic>))
                .toList() ??
            [],
        createdDate: json['createdDate']);
  }
}
