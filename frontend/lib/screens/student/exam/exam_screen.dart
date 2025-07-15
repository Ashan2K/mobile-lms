import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/exam_provider.dart';
import 'components/exam_app_bar.dart';
import 'components/question_number_panel.dart';
import 'components/question_view.dart';
import 'components/exam_navigation.dart';
import '../../../models/mock_exam.dart';

class ExamScreen extends StatefulWidget {
  final MockExam mockExam;
  const ExamScreen({Key? key, required this.mockExam}) : super(key: key);

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ExamProvider>()
          .loadQuestions(widget.mockExam.bankId, widget.mockExam.audioBankId);
      context.read<ExamProvider>().initAudioPlayer();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExamProvider>(
      builder: (context, examProvider, child) {
        if (examProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (examProvider.questions == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load questions'),
                  ElevatedButton(
                    onPressed: () => examProvider.loadQuestions(
                      widget.mockExam.bankId,
                      widget.mockExam.audioBankId,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: ExamAppBar(
            currentQuestionIndex: examProvider.currentQuestionIndex,
            onClose: () => Navigator.pop(context),
          ),
          body: Column(
            children: [
              // Progress and Timer
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Text(
                      'Question ${examProvider.currentQuestionIndex + 1}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    Text(
                      ' of ${examProvider.questions!.length}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF666666),
                      ),
                    ),
                    if (examProvider.currentQuestionIndex >= 20)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Listening',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    const Spacer(),
                    if (examProvider.currentQuestionIndex >= 20 &&
                        examProvider.currentQuestionIndex < 40)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              examProvider.isAudioPlaying
                                  ? Icons.volume_up
                                  : Icons.volume_off,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Play ${examProvider.audioPlayCount + 1}/3',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 16),
                    const Icon(Icons.timer_outlined),
                    const SizedBox(width: 8),
                    const Text(
                      '46:00',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                  ],
                ),
              ),

              // Question number panel
              QuestionNumberPanel(
                totalQuestions: examProvider.questions!.length,
                currentQuestionIndex: examProvider.currentQuestionIndex,
                answeredQuestions: examProvider.questions!
                    .map((q) => q.selectedAnswer != null)
                    .toList(),
                onQuestionSelected: examProvider.navigateToQuestion,
                canNavigateToQuestion: examProvider.canNavigateToQuestion,
              ),

              // Questions and options
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: examProvider.isAudioPlaying
                      ? const NeverScrollableScrollPhysics()
                      : null,
                  onPageChanged: examProvider.navigateToQuestion,
                  itemCount: examProvider.questions!.length,
                  itemBuilder: (context, index) {
                    return QuestionView(
                      question: examProvider.questions![index],
                      questionIndex: index,
                      isAudioPlaying: examProvider.isAudioPlaying,
                      audioPlayCount: examProvider.audioPlayCount,
                      onAnswerSelected: examProvider.selectAnswer,
                    );
                  },
                ),
              ),

              // Navigation buttons
              ExamNavigation(
                currentQuestionIndex: examProvider.currentQuestionIndex,
                totalQuestions: examProvider.questions!.length,
                isAudioPlaying: examProvider.isAudioPlaying,
                canNavigateToPrevious: examProvider.currentQuestionIndex > 0 &&
                    examProvider.canNavigateToQuestion(
                        examProvider.currentQuestionIndex - 1),
                canNavigateToNext: examProvider.currentQuestionIndex <
                    examProvider.questions!.length - 1,
                onPrevious: () => examProvider
                    .navigateToQuestion(examProvider.currentQuestionIndex - 1),
                onNext: () => examProvider
                    .navigateToQuestion(examProvider.currentQuestionIndex + 1),
                onSubmit: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
