import 'package:flutter/material.dart';
import 'package:frontend/services/mock_exam_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/mcq_question.dart';
import '../../config/constants.dart';

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
      _saveCurrentQuestion();
      setState(() {
        _currentQuestionIndex = index;
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
        title: Text(
            'Question ${_currentQuestionIndex + 1}/${AppConstants.questionsCount}'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[100],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(AppConstants.questionsCount, (index) {
                  final isAnswered = _questions[index] != null;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () => _navigateToQuestion(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentQuestionIndex == index
                            ? Colors.blue[700]
                            : isAnswered
                                ? Colors.green
                                : Colors.grey[300],
                        foregroundColor: _currentQuestionIndex == index
                            ? Colors.white
                            : isAnswered
                                ? Colors.white
                                : Colors.black87,
                        minimumSize: const Size(40, 40),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text('${index + 1}'),
                    ),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _questionController,
                      decoration: const InputDecoration(
                        labelText: 'Question',
                        border: OutlineInputBorder(),
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
                    const SizedBox(height: 16),
                    ...List.generate(4, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _optionControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Option ${index + 1}',
                                  border: const OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an option';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Radio<int>(
                              value: index,
                              groupValue: _correctAnswerIndex,
                              onChanged: (value) {
                                setState(() {
                                  _correctAnswerIndex = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentQuestionIndex > 0)
                          ElevatedButton.icon(
                            onPressed: () =>
                                _navigateToQuestion(_currentQuestionIndex - 1),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Previous'),
                          ),
                        if (_currentQuestionIndex <
                            AppConstants.questionsCount - 1)
                          ElevatedButton.icon(
                            onPressed: () =>
                                _navigateToQuestion(_currentQuestionIndex + 1),
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Next'),
                          ),
                        if (_currentQuestionIndex ==
                            AppConstants.questionsCount - 1)
                          ElevatedButton(
                            onPressed: () {
                              _saveCurrentQuestion();
                              if (_questions.every((q) => q != null)) {
                                // Convert List<MCQQuestion?> to List<MCQQuestion>
                                final nonNullQuestions = _questions
                                    .where((q) => q != null)
                                    .map((q) => q!)
                                    .toList();
                                Navigator.pop(context, nonNullQuestions);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please complete all questions before submitting'),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Submit All Questions'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
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
