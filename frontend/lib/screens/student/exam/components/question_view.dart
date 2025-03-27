import 'package:flutter/material.dart';
import '../../../../models/exam_question.dart';

class QuestionView extends StatelessWidget {
  final ExamQuestion question;
  final int questionIndex;
  final bool isAudioPlaying;
  final int audioPlayCount;
  final Function(String) onAnswerSelected;

  const QuestionView({
    Key? key,
    required this.question,
    required this.questionIndex,
    required this.isAudioPlaying,
    required this.audioPlayCount,
    required this.onAnswerSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (questionIndex >= 20 && questionIndex < 40)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isAudioPlaying ? Icons.volume_up : Icons.volume_off,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isAudioPlaying
                        ? 'Playing audio... (${audioPlayCount + 1}/3)'
                        : 'Audio will play automatically',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 32),
          ...question.options.asMap().entries.map((entry) {
            final isSelected = question.selectedAnswer == entry.value;
            return GestureDetector(
              onTap:
                  isAudioPlaying ? null : () => onAnswerSelected(entry.value),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[50] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.blue[700] : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? Colors.blue[700]!
                              : Colors.grey[400]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + entry.key),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.blue[700]
                              : const Color(0xFF1E1E1E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
