import 'mcq_question.dart';
import 'audio_question.dart';

class QuestionBank {
  final String id;
  final String title;
  final String type; // 'mcq' or 'audio'
  final List<dynamic> questions;
  final DateTime? createdDate;

  QuestionBank({
    required this.id,
    required this.title,
    required this.type,
    required this.questions,
    this.createdDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'questions': questions
          .map((q) => type == 'mcq'
              ? (q as MCQQuestion).toJson()
              : (q as AudioQuestion).toJson())
          .toList(),
      'createdDate': createdDate?.toIso8601String(),
    };
  }

  factory QuestionBank.fromJson(Map<String, dynamic> json) {
    final type = json['type'] ?? 'mcq';

    DateTime? parseCreatedDate(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        return DateTime.tryParse(value);
      }
      if (value is Map && value.containsKey('_seconds')) {
        int seconds = value['_seconds'] as int;
        int nanoseconds = value['_nanoseconds'] as int? ?? 0;
        return DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanoseconds / 1000000).round(),
        );
      }
      return null;
    }

    return QuestionBank(
      id: json['id']?.toString() ?? '',
      title: json['title'],
      type: type,
      questions: (json['questions'] as List?)
              ?.map((q) => type == 'mcq'
                  ? MCQQuestion.fromJson(q as Map<String, dynamic>)
                  : AudioQuestion.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
      createdDate: parseCreatedDate(json['createdAt']),
    );
  }
}
