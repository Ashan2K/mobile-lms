import 'package:flutter/material.dart';
import '../../models/audio_question.dart';
import '../../config/constants.dart';
import '../student/exam/components/question_number_panel.dart';

class AddAudioQuestion extends StatefulWidget {
  final List<AudioQuestion>? initialQuestions;

  const AddAudioQuestion({
    Key? key,
    this.initialQuestions,
  }) : super(key: key);

  @override
  State<AddAudioQuestion> createState() => _AddAudioQuestionState();
}

class _AddAudioQuestionState extends State<AddAudioQuestion> {
  final List<AudioQuestion> _questions = [];
  int _currentIndex = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuestions != null) {
      _questions.addAll(widget.initialQuestions!);
    }
    // Add empty questions if in development mode
    if (AppConstants.isDevelopment && _questions.isEmpty) {
      for (int i = 0; i < AppConstants.questionsCount; i++) {
        _questions.add(
          AudioQuestion(
            options: List.generate(4, (index) => 'Option ${index + 1}'),
            answer: 0,
            audioUrl: 'https://example.com/audio$i.mp3',
          ),
        );
      }
    }
    // Add first question if empty
    if (_questions.isEmpty) {
      _addQuestion();
    }
  }

  void _addQuestion() {
    setState(() {
      _questions.add(
        AudioQuestion(
          options: List.generate(4, (index) => ''),
          answer: 0,
          audioUrl: '',
        ),
      );
    });
  }

  void _removeCurrentQuestion() {
    if (_questions.length <= 1) return; // Keep at least one question

    setState(() {
      _questions.removeAt(_currentIndex);
      if (_currentIndex >= _questions.length) {
        _currentIndex = _questions.length - 1;
      }
    });
  }

  void _updateOptions(int optionIndex, String value) {
    setState(() {
      _questions[_currentIndex].options[optionIndex] = value;
    });
  }

  void _updateAnswer(int value) {
    setState(() {
      _questions[_currentIndex].answer = value;
    });
  }

  void _updateAudioUrl(String url) {
    setState(() {
      _questions[_currentIndex].audioUrl = url;
    });
  }

  Future<void> _pickAudio() async {
    // TODO: Implement audio file picking
    _updateAudioUrl('https://example.com/audio$_currentIndex.mp3');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Audio file picking will be implemented soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else if (_questions.length < AppConstants.questionsCount) {
      _addQuestion();
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Audio Questions',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isSubmitting)
            TextButton.icon(
              onPressed: () {
                if (_questions.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please add at least one question'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                setState(() => _isSubmitting = true);
                Navigator.pop(context, _questions);
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
            value: (_currentIndex + 1) / AppConstants.questionsCount,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _questions.length >= AppConstants.questionsCount
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
              currentQuestionIndex: _currentIndex,
              answeredQuestions: List.generate(
                _questions.length,
                (index) =>
                    _questions[index].audioUrl.isNotEmpty &&
                    _questions[index]
                        .options
                        .every((option) => option.isNotEmpty) &&
                    _questions[index].answer >= 0,
              ),
              onQuestionSelected: (index) {
                setState(() => _currentIndex = index);
              },
              canNavigateToQuestion: (_) => true,
            ),
          ),
          // Question counter and navigation
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentIndex + 1} of ${AppConstants.questionsCount}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    if (_questions.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red[700],
                        onPressed: _removeCurrentQuestion,
                      ),
                    if (_questions.length < AppConstants.questionsCount)
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        color: Colors.blue[700],
                        onPressed: () {
                          _addQuestion();
                          _nextQuestion();
                        },
                      ),
                  ],
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Audio upload section
                      ListTile(
                        leading: const Icon(Icons.audiotrack),
                        title: Text(
                          _questions[_currentIndex].audioUrl.isEmpty
                              ? 'No audio selected'
                              : 'Audio selected',
                          style: TextStyle(
                            color: _questions[_currentIndex].audioUrl.isEmpty
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                        subtitle: _questions[_currentIndex].audioUrl.isNotEmpty
                            ? Text(
                                _questions[_currentIndex].audioUrl,
                                style: const TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_questions[_currentIndex].audioUrl.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.play_arrow),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Audio playback coming soon!'),
                                    ),
                                  );
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.upload),
                              onPressed: _pickAudio,
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      // Options
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _questions[_currentIndex].options.length,
                        itemBuilder: (context, optionIndex) {
                          return RadioListTile<int>(
                            title: TextFormField(
                              initialValue: _questions[_currentIndex]
                                  .options[optionIndex],
                              decoration: InputDecoration(
                                hintText: 'Option ${optionIndex + 1}',
                                border: const UnderlineInputBorder(),
                              ),
                              onChanged: (value) =>
                                  _updateOptions(optionIndex, value),
                            ),
                            value: optionIndex,
                            groupValue: _questions[_currentIndex].answer,
                            onChanged: (value) {
                              if (value != null) _updateAnswer(value);
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
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _currentIndex > 0 ? _previousQuestion : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                  ),
                ),
                Text(
                  '${_currentIndex + 1}/${_questions.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _currentIndex < AppConstants.questionsCount - 1
                      ? _nextQuestion
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
}
