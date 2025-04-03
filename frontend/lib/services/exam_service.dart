import '../models/exam_question.dart';

class ExamService {
  // TODO: Replace with actual API calls when backend is ready
  Future<List<ExamQuestion>> getExamQuestions() async {
    // TODO: Implement actual API call to fetch questions
    // For now, return mock data
    return List.generate(
      40,
      (index) => ExamQuestion(
        question: 'Sample question ${index + 1}',
        options: ['Option A', 'Option B', 'Option C', 'Option D'],
        audioUrl: index >= 20 ? 'assets/audio/sample.mp3' : null,
      ),
    );
  }

  Future<void> submitExam(List<ExamQuestion> answers) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));
    print('Exam submitted with ${answers.length} answers');
  }
}
