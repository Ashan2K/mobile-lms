import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../../models/audio_question.dart';
import '../../config/constants.dart';
import '../student/exam/components/question_number_panel.dart';
import 'package:audioplayers/audioplayers.dart';

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
  bool _isUploading = false;
  final List<TextEditingController> _optionControllers =
      List.generate(4, (_) => TextEditingController());
  late final AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
    // Always initialize with fixed number of empty questions
    _questions.clear();
    for (int i = 0; i < AppConstants.questionsCount; i++) {
      if (widget.initialQuestions != null &&
          i < widget.initialQuestions!.length) {
        _questions.add(widget.initialQuestions![i]);
      } else {
        _questions.add(AudioQuestion(
          options: List.generate(4, (index) => ''),
          answer: 0,
          audioUrl: '',
        ));
      }
    }
    _loadCurrentQuestionToControllers();
  }

  void _loadCurrentQuestionToControllers() {
    for (int i = 0; i < 4; i++) {
      _optionControllers[i].text = _questions[_currentIndex].options[i];
    }
  }

  void _saveCurrentQuestionDraft() {
    for (int i = 0; i < 4; i++) {
      _questions[_currentIndex].options[i] = _optionControllers[i].text;
    }
    // answer and audioUrl are already updated via UI events
  }

  void _nextQuestion() {
    _saveCurrentQuestionDraft();
    if (_currentIndex < AppConstants.questionsCount - 1) {
      setState(() {
        _currentIndex++;
        _loadCurrentQuestionToControllers();
      });
    }
  }

  void _previousQuestion() {
    _saveCurrentQuestionDraft();
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _loadCurrentQuestionToControllers();
      });
    }
  }

  void _updateAudioUrl(String url) {
    setState(() {
      _questions[_currentIndex].audioUrl = url;
    });
  }

  Future<void> _pickAudio() async {
    // Prevent user from starting another upload while one is in progress
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // 1. Pick the audio file
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      // 2. Handle if the user cancels the picker
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No file selected.'),
              backgroundColor: Colors.orange),
        );
        return; // Early exit
      }

      final String filePath = result.files.single.path!;
      final String fileName = result.files.single.name;
      final File file = File(filePath);

      // 3. Create a unique path in Firebase Storage

      final String uniqueFileName =
          '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child(
              'audio_questions') // A top-level folder for all audio questions
          .child(uniqueFileName);

      print('✅ 2. Created Firebase Storage reference.');

      // 4. Upload the file
      print('⏳ 3. Starting file upload...');
      // This is the fix
      final UploadTask uploadTask = storageRef.putFile(
        file,
        SettableMetadata(), // Add this empty metadata object
      );
      print('⏳ 3.1. UploadTask created, awaiting completion...');
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print(
            'Upload progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
      }, onError: (e) {
        print('Upload error: $e');
      });
      final TaskSnapshot snapshot = await uploadTask;
      print('✅ 3.2. Upload complete, getting download URL...');
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      print('✅ 3.3. Download URL obtained: $downloadUrl');

      // 5. Update the UI with the new URL
      _updateAudioUrl(
          downloadUrl); // Your existing function to update the model

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Audio uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // 6. Reset the uploading state
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
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
                _saveCurrentQuestionDraft();
                final allQuestionsFilled = _questions.every((q) =>
                    q.audioUrl.isNotEmpty &&
                    q.options.every((option) => option.isNotEmpty) &&
                    q.answer >= 0);
                if (allQuestionsFilled) {
                  setState(() => _isSubmitting = true);
                  Navigator.pop(context, _questions);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Please complete all questions before submitting'),
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
                AppConstants.questionsCount,
                (index) =>
                    _questions[index].audioUrl.isNotEmpty &&
                    _questions[index]
                        .options
                        .every((option) => option.isNotEmpty) &&
                    _questions[index].answer >= 0,
              ),
              onQuestionSelected: (index) {
                _saveCurrentQuestionDraft();
                setState(() {
                  _currentIndex = index;
                  _loadCurrentQuestionToControllers();
                });
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
                // No delete/add buttons
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
                            // Show a loading spinner if uploading, otherwise show the buttons
                            if (_isUploading)
                              const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 3),
                                ),
                              )
                            else ...[
                              // The '...' is the collection-if operator
                              if (_questions[_currentIndex].audioUrl.isNotEmpty)
                                IconButton(
                                  icon: Icon(_isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow),
                                  onPressed: () {
                                    if (_questions[_currentIndex]
                                        .audioUrl
                                        .isNotEmpty) {
                                      if (_isPlaying) {
                                        _audioPlayer.pause();
                                      } else {
                                        _audioPlayer.stop();
                                        _audioPlayer.play(UrlSource(
                                            _questions[_currentIndex]
                                                .audioUrl));
                                      }
                                    }
                                  },
                                ),
                              IconButton(
                                icon: const Icon(Icons.upload),
                                onPressed:
                                    _pickAudio, // This now triggers the real upload
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Divider(),
                      // Options
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        itemBuilder: (context, optionIndex) {
                          return RadioListTile<int>(
                            title: TextFormField(
                              controller: _optionControllers[optionIndex],
                              decoration: InputDecoration(
                                hintText: 'Option ${optionIndex + 1}',
                                border: const UnderlineInputBorder(),
                              ),
                              onChanged: (value) {
                                _questions[_currentIndex].options[optionIndex] =
                                    value ?? '';
                              },
                            ),
                            value: optionIndex,
                            groupValue: _questions[_currentIndex].answer,
                            onChanged: (value) {
                              setState(() {
                                _questions[_currentIndex].answer = value!;
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
