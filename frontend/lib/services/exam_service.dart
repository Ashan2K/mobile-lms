import '../models/exam_question.dart';

class ExamService {
  // TODO: Replace with actual API calls when backend is ready
  Future<List<ExamQuestion>> getExamQuestions() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Part 1: Reading questions (1-20)
    final readingQuestions = List.generate(
      20,
      (index) => ExamQuestion(
        question:
            'Reading Question ${index + 1}: What is the correct meaning of the word "안녕하세요"?',
        options: [
          'Hello',
          'Goodbye',
          'Thank you',
          'Sorry',
        ],
      ),
    );

    // Part 2: Listening questions (21-40)
    final listeningQuestions = List.generate(
      20,
      (index) => ExamQuestion(
        question: 'Listen to the audio and choose the correct answer.',
        options: [
          'They are discussing work schedule',
          'They are ordering food',
          'They are introducing themselves',
          'They are asking for directions',
        ],
        audioUrl: 'assets/audio/question_${index + 21}.mp3',
      ),
    );

    return [...readingQuestions, ...listeningQuestions];
  }

  Future<void> submitExam(List<ExamQuestion> answers) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));
    print('Exam submitted with ${answers.length} answers');
  }
}
