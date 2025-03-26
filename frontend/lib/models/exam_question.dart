class ExamQuestion {
  final String question;
  final List<String> options;
  String? selectedAnswer;
  final String? audioUrl; // URL for the audio file (null for reading questions)

  ExamQuestion({
    required this.question,
    required this.options,
    this.selectedAnswer,
    this.audioUrl,
  });
}

// Mock data for testing
List<ExamQuestion> getMockExamQuestions() {
  // Part 1: Reading questions (1-20)
  final readingQuestions = List.generate(
    20,
    (index) => ExamQuestion(
      question: 'Reading Question ${index + 1}: Lorem ipsum dolor sit amet?',
      options: [
        'Option A for question ${index + 1}',
        'Option B for question ${index + 1}',
        'Option C for question ${index + 1}',
        'Option D for question ${index + 1}',
      ],
    ),
  );

  // Part 2: Listening questions (21-40)
  final listeningQuestions = List.generate(
    20,
    (index) => ExamQuestion(
      question: 'Listening Question ${index + 21}',
      options: [
        'Option A for question ${index + 21}',
        'Option B for question ${index + 21}',
        'Option C for question ${index + 21}',
        'Option D for question ${index + 21}',
      ],
      audioUrl: 'assets/audio/question_${index + 21}.mp3',
    ),
  );

  return [...readingQuestions, ...listeningQuestions];
}
