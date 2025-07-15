import 'package:flutter/material.dart';
import '../../models/question_bank.dart';
import '../../services/mock_exam_service.dart';

class MockExamCreationDialog extends StatefulWidget {
  final List<QuestionBank> questionBanks;
  final List<QuestionBank> questionAudioBanks;

  const MockExamCreationDialog({
    Key? key,
    required this.questionBanks,
    required this.questionAudioBanks,
  }) : super(key: key);

  @override
  State<MockExamCreationDialog> createState() => _MockExamCreationDialogState();
}

class _MockExamCreationDialogState extends State<MockExamCreationDialog> {
  final MockExamService _mockExamService = MockExamService();
  final _formKey = GlobalKey<FormState>();
  final _examNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  QuestionBank? _selectedMCQBank;
  QuestionBank? _selectedAudioBank;
  String _selectedVisibility = 'batch'; // 'batch' or 'course'
  bool _isCreating = false;
  String? _selectedCourseId;

  // Sample data for visibility options
  final List<Map<String, String>> _batchOptions = [
    {'id': 'batch1', 'name': 'Batch 23'},
    {'id': 'batch2', 'name': 'Batch 24'},
    {'id': 'batch3', 'name': 'Batch 25'},
  ];

  final List<Map<String, String>> _courseOptions = [
    {'id': 'course1', 'name': 'EPS-TOPIK Basic'},
    {'id': 'course2', 'name': 'EPS-TOPIK Intermediate'},
    {'id': 'course3', 'name': 'EPS-TOPIK Advanced'},
  ];

  @override
  void dispose() {
    _examNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<QuestionBank> get mcqBanks =>
      widget.questionBanks.where((bank) => bank.type == 'mcq').toList();

  List<QuestionBank> get audioBanks =>
      widget.questionAudioBanks.where((bank) => bank.type == 'audio').toList();

  Future<void> _createMockExam() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMCQBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an MCQ question bank'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedAudioBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an audio question bank'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      print('Creating mock exam with:'
          '\nExam Name:  ${_examNameController.text} '
          '\nDescription: ${_descriptionController.text} '
          '\nMCQ Bank: ${_selectedMCQBank!.id}'
          '\nAudio Bank: ${_selectedAudioBank!.title}'
          '\nVisibility: $_selectedVisibility');
      await _mockExamService.createMockExam(
        _examNameController.text,
        _descriptionController.text,
        _selectedMCQBank!.id,
        _selectedAudioBank!.id,
        _selectedVisibility,
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mock exam created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating mock exam: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.assignment,
                        color: Colors.blue[700],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Create Mock Exam',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _isCreating
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Exam Name
                TextFormField(
                  controller: _examNameController,
                  decoration: InputDecoration(
                    labelText: 'Exam Name',
                    hintText: 'Enter exam name (e.g., EPS-TOPIK Mock Exam 001)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.edit),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an exam name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter a description for the exam',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.description),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // MCQ Question Bank Dropdown
                DropdownButtonFormField<QuestionBank>(
                  value: _selectedMCQBank,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'MCQ Question Bank',
                    hintText: 'Select MCQ question bank',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.question_answer),
                  ),
                  items: mcqBanks.map((bank) {
                    return DropdownMenuItem<QuestionBank>(
                      value: bank,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${bank.title ?? 'Untitled'} (${bank.questions.length} questions)',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (QuestionBank? value) {
                    setState(() {
                      _selectedMCQBank = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select an MCQ question bank';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Audio Question Bank Dropdown
                DropdownButtonFormField<QuestionBank>(
                  value: _selectedAudioBank,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Audio Question Bank',
                    hintText: 'Select audio question bank',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.headphones),
                  ),
                  items: audioBanks.map((bank) {
                    return DropdownMenuItem<QuestionBank>(
                      value: bank,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${bank.title ?? 'Untitled'} (${bank.questions.length} questions)',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (QuestionBank? value) {
                    setState(() {
                      _selectedAudioBank = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select an audio question bank';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Exam Visibility Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedVisibility,
                  decoration: InputDecoration(
                    labelText: 'Exam Visibility',
                    hintText: 'Select visibility option',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.visibility),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: 'batch',
                      child: Row(
                        children: [
                          const Icon(Icons.group, size: 20),
                          const SizedBox(width: 8),
                          const Text('Batch'),
                        ],
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'course',
                      child: Row(
                        children: [
                          const Icon(Icons.school, size: 20),
                          const SizedBox(width: 8),
                          const Text('Course'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (String? value) {
                    setState(() {
                      _selectedVisibility = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isCreating
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isCreating ? null : _createMockExam,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isCreating
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Create Exam',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
