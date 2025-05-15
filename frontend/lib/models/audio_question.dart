class AudioQuestion {
  List<String> options;
  int answer;
  String audioUrl;

  AudioQuestion({
    required this.options,
    required this.answer,
    required this.audioUrl,
  });

  factory AudioQuestion.fromJson(Map<String, dynamic> json) {
    return AudioQuestion(
      options:
          (json['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
      answer: json['answer'],
      audioUrl: json['audioUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'options': options,
      'answer': answer,
      'audioUrl': audioUrl,
    };
  }
}
