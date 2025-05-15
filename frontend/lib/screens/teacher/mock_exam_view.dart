import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/question_bank.dart';
import '../../models/mcq_question.dart';
import '../../models/audio_question.dart';
import '../../providers/question_bank_provider.dart';
import '../../config/constants.dart';
import 'add_mcq_question.dart';
import 'add_audio_question.dart';

class MockExamView extends StatefulWidget {
  const MockExamView({Key? key}) : super(key: key);

  @override
  State<MockExamView> createState() => _MockExamViewState();
}

class _MockExamViewState extends State<MockExamView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuestionBankProvider>().loadQuestionBanks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Question Management",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue[700],
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Colors.blue[700],
          tabs: const [
            Tab(
              icon: Icon(Icons.question_answer),
              text: "MCQ",
            ),
            Tab(
              icon: Icon(Icons.headphones),
              text: "Audio",
            ),
            Tab(
              icon: Icon(Icons.assignment),
              text: "Mock Exams",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMCQQuestionsTab(),
          _buildAudioQuestionsTab(),
          _buildMockExamsTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    final icons = [Icons.add_circle, Icons.audiotrack, Icons.assignment];
    final labels = ['Add MCQ', 'Add Audio', 'Create Exam'];

    return FloatingActionButton.extended(
      onPressed: () {
        switch (_tabController.index) {
          case 0:
            _createQuestionBank();
            break;
          case 1:
            _createAudioQuestion();
            break;
          case 2:
            _createMockExam();
            break;
        }
      },
      backgroundColor: Colors.blue[700],
      icon: Icon(icons[_tabController.index]),
      label: Text(labels[_tabController.index]),
    );
  }

  Widget _buildMCQQuestionsTab() {
    return Consumer<QuestionBankProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return _buildErrorState(provider.error!, provider.loadQuestionBanks);
        }

        final questionBanks = provider.questionBanks;
        if (questionBanks == null || questionBanks.isEmpty) {
          return _buildEmptyState("MCQ Questions");
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: questionBanks.length,
          itemBuilder: (context, index) {
            final bank = questionBanks[index];
            return _buildQuestionBankCard(bank);
          },
        );
      },
    );
  }

  Widget _buildAudioQuestionsTab() {
    // TODO: Implement audio questions tab
    return _buildEmptyState("Audio Questions");
  }

  Widget _buildMockExamsTab() {
    // TODO: Implement mock exams tab
    return _buildEmptyState("Mock Exams");
  }

  Widget _buildEmptyState(String itemType) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            itemType.contains("Audio")
                ? Icons.audiotrack
                : itemType.contains("Mock")
                    ? Icons.assignment
                    : Icons.quiz,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No $itemType found',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create new $itemType to get started',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
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
            error,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionBankCard(QuestionBank bank) {
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
  }

  void _createAudioQuestion() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddAudioQuestion(),
      ),
    );

    if (result != null && result is List<AudioQuestion>) {
      final title = await _showTitleDialog();
      if (title != null) {
        try {
          // TODO: Implement audio question bank creation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Audio question bank created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error creating audio question bank: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  void _createMockExam() {
    // TODO: Implement mock exam creation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mock exam creation coming soon!'),
        backgroundColor: Colors.blue,
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
