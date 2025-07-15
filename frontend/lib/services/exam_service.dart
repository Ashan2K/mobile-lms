import '../models/exam_question.dart';
import '../models/question_bank.dart';
import '../models/mcq_question.dart';
import '../models/audio_question.dart';
import 'mock_exam_service.dart';

class ExamService {
  final MockExamService _mockExamService = MockExamService();

  Future<List<ExamQuestion>> getMockExamQuestions(
      String mcqBankId, String audioBankId) async {
    try {
      final results = await Future.wait([
        _mockExamService.getMcqQuestionBank(mcqBankId),
        _mockExamService.getAudioQuestionBank(audioBankId),
      ]);
      final mcqBank = results[0];
      final audioBank = results[1];

      final mcqQuestions = mcqBank.questions
          .map((q) => ExamQuestion(
                question: (q as MCQQuestion).question,
                options: q.options,
                selectedAnswer: null,
                audioUrl: null,
                correctAnswer:
                    q.correctAnswerIndex.toString(), // Convert int to String
              ))
          .toList();

      final audioQuestions = audioBank.questions
          .map((q) => ExamQuestion(
                question: "Listen to the audio and answer",
                options: (q as AudioQuestion).options,
                selectedAnswer: null,
                audioUrl: q.audioUrl,
                correctAnswer:
                    q.answer.toString(), // Assuming correctAnswer is a String
              ))
          .toList();

      //debugging printing
      for (var i = 0; i < mcqQuestions.length; i++) {
        print('MCQ Question ${i + 1}: ${mcqQuestions[i].question}');
        print('Options: ${mcqQuestions[i].options}');
        print('Correct Answer: ${mcqQuestions[i].correctAnswer}');
      }

      for (var i = 0; i < audioQuestions.length; i++) {
        print('Audio Question ${i + 1}: ${audioQuestions[i].question}');
        print('Audio URL: ${audioQuestions[i].audioUrl}');
        print('Options: ${audioQuestions[i].options}');
        print('Correct Answer: ${audioQuestions[i].correctAnswer}');
      }

      if (mcqQuestions.length != 20 || audioQuestions.length != 20) {
        throw Exception(
            'Invalid number of questions. Expected 20 for each type.');
      }

      mcqQuestions.shuffle();
      audioQuestions.shuffle();

      return [...mcqQuestions, ...audioQuestions];
    } catch (e) {
      print('Error fetching mock exam questions: $e');
      return [];
    }
  }

  // Future<List<ExamQuestion>> getExamQuestions() async {
  //   // Simulate API delay
  //   await Future.delayed(const Duration(seconds: 1));

  //   // Part 1: Reading questions (1-20)
  //   final readingQuestions = List.generate(
  //     20,
  //     (index) => ExamQuestion(
  //       question:
  //           'Reading Question ${index + 1}: What is the correct meaning of the word "안녕하세요"?',
  //       options: [
  //         'Hello',
  //         'Goodbye',
  //         'Thank you',
  //         'Sorry',
  //       ],
  //     ),
  //   );

  //   // Part 2: Listening questions (21-40)
  //   final listeningQuestions = List.generate(
  //     20,
  //     (index) => ExamQuestion(
  //       question: 'Listen to the audio and choose the correct answer.',
  //       options: [
  //         'They are discussing work schedule',
  //         'They are ordering food',
  //         'They are introducing themselves',
  //         'They are asking for directions',
  //       ],
  //       audioUrl: 'assets/audio/question_${index + 21}.mp3',
  //     ),
  //   );

  //   return [...readingQuestions, ...listeningQuestions];
  // }

  Future<void> submitExam(List<ExamQuestion> answers) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));
    print('Exam submitted with  [1m${answers.length} [22m answers');
  }

  /// Grades the exam and returns a result map.
  Map<String, dynamic> gradeExam(List<ExamQuestion> questions) {
    int total = questions.length;
    int correct = 0;
    int part1Correct = 0;
    int part2Correct = 0;

    for (int i = 0; i < questions.length; i++) {
      if (questions[i].selectedAnswer == questions[i].correctAnswer) {
        correct++;
        if (i < 20) {
          part1Correct++;
        } else {
          part2Correct++;
        }
      }
    }

    return {
      'total': total,
      'correct': correct,
      'part1Correct': part1Correct,
      'part2Correct': part2Correct,
    };
  }
}
