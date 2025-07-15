import 'package:flutter/material.dart';
import 'package:frontend/services/mock_exam_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/mcq_question.dart';
import '../../config/constants.dart';
import '../student/exam/components/question_number_panel.dart';

class AddMCQQuestion extends StatefulWidget {
  final List<MCQQuestion>? initialQuestions;

  const AddMCQQuestion({
    Key? key,
    this.initialQuestions,
  }) : super(key: key);

  @override
  State<AddMCQQuestion> createState() => _AddMCQQuestionState();
}

class _AddMCQQuestionState extends State<AddMCQQuestion> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _titleController =
      TextEditingController(); // Add this near other controllers

  final List<TextEditingController> _optionControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  int _correctAnswerIndex = 0;
  File? _imageFile;
  int _currentQuestionIndex = 0;
  late final List<MCQQuestion?> _questions;

  @override
  void initState() {
    super.initState();
    _questions = List.generate(
      AppConstants.questionsCount,
      (index) => widget.initialQuestions?.elementAtOrNull(index),
    );
    if (widget.initialQuestions != null &&
        widget.initialQuestions!.isNotEmpty) {
      _loadQuestion(widget.initialQuestions!.first);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  void _saveCurrentQuestion() {
    if (_formKey.currentState!.validate()) {
      final question = MCQQuestion(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        question: _questionController.text,
        options: _optionControllers.map((c) => c.text).toList(),
        correctAnswerIndex: _correctAnswerIndex,
        imageUrl: _imageFile != null ? _imageFile!.path : null,
      );
      setState(() {
        _questions[_currentQuestionIndex] = question;
      });
    }
  }

  void _saveCurrentQuestionDraft() {
    final question = MCQQuestion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      question: _questionController.text,
      options: _optionControllers.map((c) => c.text).toList(),
      correctAnswerIndex: _correctAnswerIndex,
      imageUrl: _imageFile != null ? _imageFile!.path : null,
    );
    setState(() {
      _questions[_currentQuestionIndex] = question;
    });
  }

  void _loadQuestion(MCQQuestion question) {
    _questionController.text = question.question;
    for (var i = 0; i < question.options.length; i++) {
      _optionControllers[i].text = question.options[i];
    }
    _correctAnswerIndex = question.correctAnswerIndex;
    if (question.imageUrl != null) {
      _imageFile = File(question.imageUrl!);
    }
  }

  void _navigateToQuestion(int index) {
    if (index >= 0 && index < AppConstants.questionsCount) {
      _saveCurrentQuestionDraft();
      setState(() {
        _currentQuestionIndex = index;
        // Ensure the list is always the correct length
        while (_questions.length < AppConstants.questionsCount) {
          _questions.add(null);
        }
        if (_questions[index] == null) {
          _questions[index] = MCQQuestion(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            question: '',
            options: List.generate(4, (_) => ''),
            correctAnswerIndex: 0,
            imageUrl: null,
          );
        }
      });
      final question = _questions[index];
      if (question != null) {
        _loadQuestion(question);
      } else {
        // Reset form for new question
        _questionController.clear();
        for (var controller in _optionControllers) {
          controller.clear();
        }
        _correctAnswerIndex = 0;
        _imageFile = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add MCQ Questions',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              _saveCurrentQuestion();
              if (_questions.every((q) => q != null)) {
                final nonNullQuestions =
                    _questions.where((q) => q != null).map((q) => q!).toList();
                Navigator.pop(context, nonNullQuestions);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Please complete all questions before submitting'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('Submit'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.green[700],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / AppConstants.questionsCount,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _questions.where((q) => q != null).length >=
                      AppConstants.questionsCount
                  ? Colors.green
                  : Colors.blue,
            ),
          ),
          // Question number panel
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: QuestionNumberPanel(
              totalQuestions: AppConstants.questionsCount,
              currentQuestionIndex: _currentQuestionIndex,
              answeredQuestions: List.generate(
                _questions.length,
                (index) =>
                    _questions[index] != null &&
                    _questions[index]!.question.isNotEmpty &&
                    _questions[index]!
                        .options
                        .every((option) => option.isNotEmpty),
              ),
              onQuestionSelected: (index) {
                _navigateToQuestion(index);
              },
              canNavigateToQuestion: (_) => true,
            ),
          ),
          // Question counter and delete
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1} of ${AppConstants.questionsCount}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_questions.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.red[700],
                    onPressed: () {
                      setState(() {
                        if (_questions.length <= 1)
                          return; // Prevent deleting last question
                        _questions.removeAt(_currentQuestionIndex);
                        if (_currentQuestionIndex >= _questions.length) {
                          _currentQuestionIndex = _questions.length - 1;
                        }
                        if (_questions.isEmpty) {
                          // Add a new empty question if all are deleted
                          _questions.add(MCQQuestion(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            question: '',
                            options: List.generate(4, (_) => ''),
                            correctAnswerIndex: 0,
                            imageUrl: null,
                          ));
                          _currentQuestionIndex = 0;
                        }
                      });
                    },
                  ),
              ],
            ),
          ),
          // Current question
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _questionController,
                          decoration: const InputDecoration(
                            labelText: 'Question',
                            border: UnderlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a question';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text('Attach Image'),
                        ),
                        if (_imageFile != null) ...[
                          const SizedBox(height: 8),
                          Image.file(
                            _imageFile!,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _imageFile = null;
                              });
                            },
                            child: const Text('Remove Image'),
                          ),
                        ],
                        const Divider(),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return RadioListTile<int>(
                              title: TextFormField(
                                controller: _optionControllers[index],
                                decoration: InputDecoration(
                                  hintText: 'Option ${index + 1}',
                                  border: const UnderlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an option';
                                  }
                                  return null;
                                },
                              ),
                              value: index,
                              groupValue: _correctAnswerIndex,
                              onChanged: (value) {
                                setState(() {
                                  _correctAnswerIndex = value!;
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _currentQuestionIndex > 0
                      ? () => _navigateToQuestion(_currentQuestionIndex - 1)
                      : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                  ),
                ),
                Text(
                  '${_currentQuestionIndex + 1}/${_questions.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed:
                      _currentQuestionIndex < AppConstants.questionsCount - 1
                          ? () => _navigateToQuestion(_currentQuestionIndex + 1)
                          : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
