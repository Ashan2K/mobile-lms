import 'package:flutter/material.dart';

class QuestionNumberPanel extends StatelessWidget {
  final int totalQuestions;
  final int currentQuestionIndex;
  final List<bool> answeredQuestions;
  final Function(int) onQuestionSelected;
  final bool Function(int) canNavigateToQuestion;

  const QuestionNumberPanel({
    Key? key,
    required this.totalQuestions,
    required this.currentQuestionIndex,
    required this.answeredQuestions,
    required this.onQuestionSelected,
    required this.canNavigateToQuestion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            totalQuestions,
            (index) {
              final isSelected = index == currentQuestionIndex;
              final hasAnswer = answeredQuestions[index];
              final isDisabled = !canNavigateToQuestion(index);

              return Container(
                width: 40,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isDisabled
                      ? Colors.grey[200]
                      : isSelected
                          ? Colors.blue[700]
                          : hasAnswer
                              ? Colors.green[50]
                              : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDisabled
                        ? Colors.grey[300]!
                        : isSelected
                            ? Colors.blue[700]!
                            : hasAnswer
                                ? Colors.green[300]!
                                : Colors.grey[300]!,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isDisabled ? null : () => onQuestionSelected(index),
                    borderRadius: BorderRadius.circular(8),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isDisabled
                              ? Colors.grey[400]
                              : isSelected
                                  ? Colors.white
                                  : hasAnswer
                                      ? Colors.green[700]
                                      : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
