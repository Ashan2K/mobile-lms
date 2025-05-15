import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/question_bank.dart';
import '../../models/mcq_question.dart';
import '../../providers/question_bank_provider.dart';
import '../../config/constants.dart';
import 'add_mcq_question.dart';

class MockExamView extends StatefulWidget {
  const MockExamView({Key? key}) : super(key: key);

  @override
  State<MockExamView> createState() => _MockExamViewState();
}

class _MockExamViewState extends State<MockExamView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuestionBankProvider>().loadQuestionBanks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Question Banks",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (AppConstants.isDevelopment)
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.developer_mode,
                      size: 16, color: Colors.orange[900]),
                  const SizedBox(width: 4),
                  Text(
                    'Dev Mode (${AppConstants.questionsCount} questions)',
                    style: TextStyle(
                      color: Colors.orange[900],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Consumer<QuestionBankProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.loadQuestionBanks,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final questionBanks = provider.questionBanks;
          if (questionBanks == null || questionBanks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.quiz,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No question banks found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a new question bank with ${AppConstants.questionsCount} questions',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: questionBanks.length,
            itemBuilder: (context, index) {
              final bank = questionBanks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    bank.title ?? 'Untitled',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        '${bank.questions.length} questions',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Created: ${bank.createdDate != null ? _formatDate(bank.createdDate!) : 'N/A'}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editQuestionBank(bank),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteQuestionBank(bank),
                      ),
                    ],
                  ),
                  onTap: () => _viewQuestionBank(bank),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createQuestionBank,
        backgroundColor: Colors.blue[700],
        icon: const Icon(Icons.add),
        label: const Text('Create Question Bank'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _createQuestionBank() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddMCQQuestion(),
      ),
    );

    debugPrint('Result type: ${result?.runtimeType}');
    debugPrint('Result: $result');

    if (result != null && result is List<MCQQuestion>) {
      final title = await _showTitleDialog();
      if (title != null) {
        try {
          await context.read<QuestionBankProvider>().createQuestionBank(
                title,
                result,
              );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Question bank created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          debugPrint('Error creating question bank: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error creating question bank: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } else {
      debugPrint('Invalid result type: ${result?.runtimeType}');
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('Invalid question data received'),
      //       backgroundColor: Colors.red,
      //     ),
      //   );
      // }
    }
  }

  Future<String?> _showTitleDialog({String? initialValue}) async {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(initialValue == null
            ? 'Enter Question Bank Title'
            : 'Edit Question Bank Title'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter a title for the question bank',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context, controller.text);
              }
            },
            child: Text(initialValue == null ? 'Create' : 'Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _editQuestionBank(QuestionBank bank) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMCQQuestion(initialQuestions: bank.questions),
      ),
    );
    if (result != null && result is List<MCQQuestion>) {
      final title = await _showTitleDialog(initialValue: "");
      if (title != null) {
        try {
          await context.read<QuestionBankProvider>().updateQuestionBank(
                bank.id,
                title,
                result,
              );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Question bank updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error updating question bank: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _deleteQuestionBank(QuestionBank bank) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question Bank'),
        content: Text('Are you sure you want to delete ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await context.read<QuestionBankProvider>().deleteQuestionBank(bank.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Question bank deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting question bank: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _viewQuestionBank(QuestionBank bank) {
    // TODO: Implement question bank view screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing question bank: '),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
