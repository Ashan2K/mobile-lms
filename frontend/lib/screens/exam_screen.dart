import 'package:flutter/material.dart';
import '../models/exam_question.dart';
import '../services/exam_service.dart';
import 'package:just_audio/just_audio.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({Key? key}) : super(key: key);

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late PageController _pageController;
  List<ExamQuestion>? _questions;
  AudioPlayer? _audioPlayer;
  final ExamService _examService = ExamService();
  int _currentQuestionIndex = 0;
  bool _part1Completed = false;
  bool _part2Completed = false;
  int _audioPlayCount = 0;
  bool _isAudioPlaying = false;
  bool _isLoading = true;
  final bool _tempDisableAudio = true; // Set to false to enable audio

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadQuestions();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      _audioPlayer = AudioPlayer();
      // Listen to audio state changes
      _audioPlayer?.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _onAudioComplete();
        }
        setState(() {
          _isAudioPlaying = state.playing;
        });
      });
    } catch (e) {
      print('Error initializing audio player: $e');
    }
  }

  Future<void> _playAudio(String audioPath) async {
    if (_tempDisableAudio) {
      // Simulate audio completion after 3 seconds
      setState(() => _isAudioPlaying = true);
      await Future.delayed(const Duration(seconds: 3));
      _onAudioComplete();
      return;
    }

    try {
      if (_audioPlayer == null) {
        await _initAudioPlayer();
      }

      setState(() => _isAudioPlaying = true);
      await _audioPlayer?.setAsset(audioPath);
      await _audioPlayer?.play();
    } catch (e) {
      print('Error playing audio: $e');
      setState(() => _isAudioPlaying = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
        );
      }
    }
  }

  void _onAudioComplete() {
    if (_currentQuestionIndex >= 20 && _currentQuestionIndex < 40) {
      setState(() {
        _audioPlayCount++;
        if (_audioPlayCount < 3) {
          // Play again if not played 3 times
          _playAudio(_questions![_currentQuestionIndex].audioUrl!);
        } else {
          // Move to next question after 3 plays
          _audioPlayCount = 0;
          _isAudioPlaying = false;
          if (_currentQuestionIndex < 39) {
            _navigateToQuestion(_currentQuestionIndex + 1);
          } else {
            // Mark Part 2 as completed
            setState(() => _part2Completed = true);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _examService.getExamQuestions();
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading questions: $e')),
        );
      }
    }
  }

  bool _canNavigateToQuestion(int index) {
    if (index < 20) {
      // Part 1 (1-20): Always accessible unless audio is playing
      return !_isAudioPlaying;
    } else {
      // Part 2 (21-40): Accessible if Part 1 is completed and following sequential order
      return _part1Completed &&
          !_part2Completed &&
          !_isAudioPlaying &&
          (index == _currentQuestionIndex ||
              index == _currentQuestionIndex + 1);
    }
  }

  bool _isPart1Complete() {
    return _questions!.sublist(0, 20).every((q) => q.selectedAnswer != null);
  }

  void _navigateToQuestion(int index) {
    if (!_canNavigateToQuestion(index)) return;

    // When moving from Part 1 to Part 2
    if (_currentQuestionIndex < 20 && index >= 20) {
      if (!_isPart1Complete()) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Complete Part 1'),
            content: const Text(
                'Please answer all questions in Part 1 (1-20) before proceeding to Part 2.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
      setState(() => _part1Completed = true);
    }

    setState(() {
      _currentQuestionIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // Start audio for Part 2 questions (21-40)
    if (index >= 20 && index < 40 && !_part2Completed) {
      _audioPlayCount = 0;
      if (_questions![index].audioUrl != null) {
        _playAudio(_questions![index].audioUrl!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_questions == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load questions'),
              ElevatedButton(
                onPressed: _loadQuestions,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () {
            // Show confirmation dialog before closing
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Exit Exam?'),
                content: const Text(
                    'Are you sure you want to exit the exam? Your progress will be lost.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Close exam screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                    ),
                    child: const Text('Exit',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: const Text(
                'EPS-TOPIK MOCK EXAM',
                style: TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _currentQuestionIndex < 20
                    ? Colors.blue[100]
                    : Colors.orange[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentQuestionIndex < 20 ? 'P1' : 'P2',
                    style: TextStyle(
                      color: _currentQuestionIndex < 20
                          ? Colors.blue[700]
                          : Colors.orange[700],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _currentQuestionIndex < 20 ? '1-20' : '21-40',
                    style: TextStyle(
                      color: _currentQuestionIndex < 20
                          ? Colors.blue[700]
                          : Colors.orange[700],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Progress and Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                Text(
                  ' of ${_questions!.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF666666),
                  ),
                ),
                if (_currentQuestionIndex >= 20)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Listening',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                if (_currentQuestionIndex >= 20 && _currentQuestionIndex < 40)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isAudioPlaying ? Icons.volume_up : Icons.volume_off,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Play ${_audioPlayCount + 1}/3',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 16),
                const Icon(Icons.timer_outlined),
                const SizedBox(width: 8),
                const Text(
                  '45:00',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ],
            ),
          ),

          // Question number panel
          SizedBox(
            height: 60,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  _questions!.length,
                  (index) {
                    final isSelected = index == _currentQuestionIndex;
                    final hasAnswer = _questions![index].selectedAnswer != null;
                    final isDisabled = !_canNavigateToQuestion(index);

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
                          onTap: isDisabled
                              ? null
                              : () => _navigateToQuestion(index),
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
          ),

          // Questions and options
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics:
                  _isAudioPlaying ? const NeverScrollableScrollPhysics() : null,
              onPageChanged: (index) {
                setState(() {
                  _currentQuestionIndex = index;
                });
              },
              itemCount: _questions!.length,
              itemBuilder: (context, index) {
                final question = _questions![index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (index >= 20 && index < 40)
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
                                _isAudioPlaying
                                    ? Icons.volume_up
                                    : Icons.volume_off,
                                color: Colors.blue[700],
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _isAudioPlaying
                                    ? 'Playing audio... (${_audioPlayCount + 1}/3)'
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
                        final isSelected =
                            question.selectedAnswer == entry.value;
                        return GestureDetector(
                          onTap: _isAudioPlaying
                              ? null
                              : () {
                                  setState(() {
                                    _questions![index].selectedAnswer =
                                        entry.value;
                                  });
                                },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue[50]
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue[700]!
                                    : Colors.grey[300]!,
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
                                    color: isSelected
                                        ? Colors.blue[700]
                                        : Colors.white,
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
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey[600],
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
              },
            ),
          ),

          // Navigation buttons
          Container(
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
                if (_currentQuestionIndex > 0 &&
                    _canNavigateToQuestion(_currentQuestionIndex - 1))
                  ElevatedButton.icon(
                    onPressed: _isAudioPlaying
                        ? null
                        : () {
                            _navigateToQuestion(_currentQuestionIndex - 1);
                          },
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
                  onPressed: _isAudioPlaying
                      ? null
                      : () {
                          if (_currentQuestionIndex < _questions!.length - 1) {
                            _navigateToQuestion(_currentQuestionIndex + 1);
                          } else {
                            // Show completion dialog
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
                                      Navigator.pop(
                                          context); // Close exam screen
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
                  icon: Icon(_currentQuestionIndex < _questions!.length - 1
                      ? Icons.arrow_forward
                      : Icons.check),
                  label: Text(_currentQuestionIndex < _questions!.length - 1
                      ? 'Next'
                      : 'Submit'),
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
          ),
        ],
      ),
    );
  }
}
