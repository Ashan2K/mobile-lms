import 'package:flutter/material.dart';

class ExamNavigation extends StatelessWidget {
  final int currentQuestionIndex;
  final int totalQuestions;
  final bool isAudioPlaying;
  final bool canNavigateToPrevious;
  final bool canNavigateToNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  const ExamNavigation({
    Key? key,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.isAudioPlaying,
    required this.canNavigateToPrevious,
    required this.canNavigateToNext,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (canNavigateToPrevious)
            ElevatedButton.icon(
              onPressed: isAudioPlaying ? null : onPrevious,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: Colors.grey[700],
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          else
            const SizedBox(width: 120),
          ElevatedButton.icon(
            onPressed: isAudioPlaying
                ? null
                : () {
                    if (currentQuestionIndex < totalQuestions - 1) {
                      onNext();
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Submit Exam?'),
                          content: const Text(
                              'Are you sure you want to submit your answers?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                                onSubmit();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                              ),
                              child: const Text('Submit'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
            icon: Icon(currentQuestionIndex < totalQuestions - 1
                ? Icons.arrow_forward
                : Icons.check),
            label: Text(
                currentQuestionIndex < totalQuestions - 1 ? 'Next' : 'Submit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
