class QuestionModel {
  String qId;
  String question;
  List<String> options;
  int answer;
  String? imageUrl;

  QuestionModel({
    required this.qId,
    required this.question,
    required this.options,
    required this.answer,
    this.imageUrl,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      qId: json['qId'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options']),
      answer: json['answer'] as int,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qId': qId,
      'question': question,
      'options': options,
      'answer': answer,
      'imageUrl': imageUrl,
    };
  }
}
