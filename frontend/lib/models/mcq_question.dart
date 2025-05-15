class MCQQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String? imageUrl;

  MCQQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'answer': correctAnswerIndex,
      'imageUrl': imageUrl,
    };
  }

  factory MCQQuestion.fromJson(Map<String, dynamic> json) {
    return MCQQuestion(
      id: json['qId']?.toString() ?? '',
      question: json['questionTxt']?.toString() ?? '',
      options:
          (json['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
      correctAnswerIndex: int.tryParse(json['answer']?.toString() ?? '0') ?? 0,
      imageUrl: json['imageUrl']?.toString(),
    );
  }
}
