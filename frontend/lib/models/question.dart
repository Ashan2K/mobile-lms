// TODO Implement this library.

class Question {
  final String category;
  final int id;
  final String questions;
  final List<String> options;
  final int answer;
  final String? imagePath;

  Question({
    required this.category,
    required this.id,
    required this.questions,
    required this.options,
    required this.answer,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'id': id,
      'questions': questions,
      'options': options,
      'answer': answer,
      'imagePath': imagePath,
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      category: json['category'],
      id: json['id'],
      questions: json['questions'],
      options: List<String>.from(json['options']),
      answer: json['answer'],
      imagePath: json['imagePath'],
    );
  }
}
