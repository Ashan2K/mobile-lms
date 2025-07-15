class ExamQuestion {
  final String question;
  final List<String> options;
  String? selectedAnswer;
  final String? audioUrl;
  String correctAnswer; // URL for the audio file (null for reading questions)

  ExamQuestion(
      {required this.question,
      required this.options,
      this.selectedAnswer,
      this.audioUrl,
      required this.correctAnswer});
}
