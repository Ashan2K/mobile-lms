import 'package:flutter/material.dart';
import '../../models/exam_question.dart';
import '../../services/exam_service.dart';
import 'package:just_audio/just_audio.dart';
import '../../models/mock_exam.dart';
import 'dart:async'; // Added for Timer

class ExamScreen extends StatefulWidget {
  final MockExam mockExam;
  const ExamScreen({Key? key, required this.mockExam}) : super(key: key);

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late PageController _pageController;
  List<ExamQuestion>? _questions;
  AudioPlayer? _audioPlayer;
  final ExamService _examService = ExamService();
  int _currentQuestionIndex = 0;
  bool _isAudioPlaying = false;
  bool _isLoading = true;
  final bool _tempDisableAudio = true; // Set to false to enable audio

  // Timer related state
  late int _totalTimeLeft; // 60 minutes total
  late int _part1TimeLeft; // 30 minutes for part 1
  late int _part2QuestionTimeLeft; // 90 seconds for each part 2 question
  Timer? _totalTimer;
  Timer? _part1Timer;
  Timer? _part2QuestionTimer;

  // Exam state flags
  String _currentPart = 'A'; // 'A', 'B', 'REVIEW_A', 'FINISHED'
  bool get _isPartA => _currentPart == 'A';
  bool get _isPartB => _currentPart == 'B';
  bool get _isReviewA => _currentPart == 'REVIEW_A';
  bool _partBFinished = false;

  static const int part1TotalSeconds = 30 * 60; // 30 minutes
  static const int part2PerQuestionSeconds = 90; // 1.5 minutes

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadQuestions();
    _initAudioPlayer();

    // Initialize timers
    _totalTimeLeft = 60 * 60; // 60 minutes
    _part1TimeLeft = part1TotalSeconds;
    _part2QuestionTimeLeft = part2PerQuestionSeconds;

    _startTotalTimer();
    _startPart1Timer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      _audioPlayer = AudioPlayer();
      // Listen to audio state changes
      _audioPlayer?.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _onAudioComplete();
        }
        if (!mounted) return;
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
      if (!mounted) return;
      // Simulate audio completion after 3 seconds
      setState(() => _isAudioPlaying = true);
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      _onAudioComplete();
      return;
    }

    try {
      if (_audioPlayer == null) {
        await _initAudioPlayer();
      }

      if (!mounted) return;
      setState(() => _isAudioPlaying = true);
      await _audioPlayer?.setUrl(audioPath); // Changed from setAsset to setUrl
      await _audioPlayer?.play();
    } catch (e) {
      print('Error playing audio: $e');
      if (!mounted) return;
      setState(() => _isAudioPlaying = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
        );
      }
    }
  }

  void _onAudioComplete() {
    if (_isPartB) {
      if (!mounted) return;
      setState(() {
        _isAudioPlaying = false;
      });
    }
  }

  void _startTotalTimer() {
    _totalTimer?.cancel();
    _totalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalTimeLeft > 0) {
        if (!mounted) return;
        setState(() {
          _totalTimeLeft--;
        });
      } else {
        _finishExam();
      }
    });
  }

  void _startPart1Timer() {
    _part1Timer?.cancel();
    _part1Timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_part1TimeLeft > 0) {
        if (!mounted) return;
        setState(() {
          _part1TimeLeft--;
        });
      } else {
        // Time for Part A is up, force move to Part B
        if (_isPartA) {
          _moveToPart2();
        }
      }
    });
  }

  void _startPart2QuestionTimer() {
    _part2QuestionTimer?.cancel();
    setState(() {
      _part2QuestionTimeLeft = part2PerQuestionSeconds;
    });
    _part2QuestionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_part2QuestionTimeLeft > 0) {
        if (!mounted) return;
        setState(() {
          _part2QuestionTimeLeft--;
        });
        if (_part2QuestionTimeLeft == 0) {
          _moveToNextPart2Question();
        }
      }
    });
  }

  void _moveToPart2() {
    // This function is called after the user confirms or time runs out.
    // The check for completion is done before calling this.
    _part1Timer?.cancel(); // Stop Part A timer

    setState(() {
      _currentPart = 'B';
      _currentQuestionIndex = 20;
    });

    _pageController.jumpToPage(20);

    _startPart2QuestionTimer();
    if (_questions != null &&
        _questions!.length > 20 &&
        _questions![20].audioUrl != null) {
      _playAudio(_questions![20].audioUrl!);
    }
  }

  void _moveToNextPart2Question() {
    _part2QuestionTimer?.cancel();

    if (_currentQuestionIndex < 39) {
      setState(() {
        _currentQuestionIndex++;
      });
      _pageController.jumpToPage(_currentQuestionIndex);
      _startPart2QuestionTimer();
      if (_questions != null &&
          _questions![_currentQuestionIndex].audioUrl != null) {
        _playAudio(_questions![_currentQuestionIndex].audioUrl!);
      }
    } else {
      // Finished all Part 2 questions
      _finishPart2();
    }
  }

  void _finishPart2() {
    _part2QuestionTimer?.cancel();
    setState(() {
      _partBFinished = true;
    });

    if (_totalTimeLeft > 0) {
      // If time left, go to review mode for Part A
      setState(() {
        _currentPart = 'REVIEW_A';
        _currentQuestionIndex = 0; // Go back to the first question of Part A
      });
      _pageController.jumpToPage(0);
    } else {
      // Otherwise, finish the exam
      _finishExam();
    }
  }

  void _finishExam() {
    if (_currentPart == 'FINISHED') return; // Avoid multiple calls

    _totalTimer?.cancel();
    _part1Timer?.cancel();
    _part2QuestionTimer?.cancel();

    setState(() {
      _currentPart = 'FINISHED';
    });

    final result = _examService.gradeExam(_questions!);
    _showResultDialog(result);
  }

  void _showResultDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Exam Finished'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Score:  ${result['correct']}  / ${result['total']}'),
            const SizedBox(height: 8),
            Text('Part 1 (Reading):  ${result['part1Correct']} / 20'),
            Text('Part 2 (Listening):  ${result['part2Correct']}  / 20'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close exam screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    _pageController.dispose();
    _totalTimer?.cancel();
    _part1Timer?.cancel();
    _part2QuestionTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _examService.getMockExamQuestions(
        widget.mockExam.bankId,
        widget.mockExam.audioBankId,
      );
      if (!mounted) return;
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
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
    // This function determines if a question in the top panel is tappable.
    if (_isPartA || _isReviewA) {
      return index < 20; // Can only navigate within Part A
    }
    // In Part B, navigation via the number panel is always disabled.
    // After Part B is finished, it remains locked.
    return false;
  }

  bool _isPart1Complete() {
    return _questions!.sublist(0, 20).every((q) => q.selectedAnswer != null);
  }

  void _navigateToQuestion(int index) {
    if (!_canNavigateToQuestion(index)) return;

    setState(() {
      _currentQuestionIndex = index;
    });

    _pageController.jumpToPage(index);
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

    // Timer display logic
    String mainTimerText;
    final totalMin = (_totalTimeLeft ~/ 60).toString().padLeft(2, '0');
    final totalSec = (_totalTimeLeft % 60).toString().padLeft(2, '0');
    mainTimerText = '$totalMin:$totalSec';

    String partTimerText;
    if (_isPartA) {
      final min = (_part1TimeLeft ~/ 60).toString().padLeft(2, '0');
      final sec = (_part1TimeLeft % 60).toString().padLeft(2, '0');
      partTimerText = 'Part A Time: $min:$sec';
    } else if (_isPartB) {
      final min = (_part2QuestionTimeLeft ~/ 60).toString().padLeft(2, '0');
      final sec = (_part2QuestionTimeLeft % 60).toString().padLeft(2, '0');
      partTimerText = 'Question Time: $min:$sec';
    } else if (_isReviewA) {
      partTimerText = 'Reviewing Part A';
    } else {
      partTimerText = 'Finished';
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF1E1E1E)),
          onPressed: () => _showExitConfirmationDialog(),
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
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _isPartA || _isReviewA
                    ? Colors.blue[50]
                    : Colors.orange[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isPartA || _isReviewA ? 'P1' : 'P2',
                    style: TextStyle(
                      color: _isPartA || _isReviewA
                          ? Colors.blue[700]
                          : Colors.orange[700],
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isPartA || _isReviewA ? '1-20' : '21-40',
                    style: TextStyle(
                      color: _isPartA || _isReviewA
                          ? Colors.blue[700]
                          : Colors.orange[700],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress and Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            'Question ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[900],
                            ),
                          ),
                          Text(
                            '${_currentQuestionIndex + 1}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                          Text(
                            ' of ${_questions!.length}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.blue[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Main Exam Timer
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined,
                              color: Color(0xFF1E1E1E)),
                          const SizedBox(width: 8),
                          Text(
                            mainTimerText, // Always show total time left
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Part-specific Timer
                if (_isPartA || _isPartB)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isPartA ? Colors.blue[100] : Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      partTimerText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _isPartA ? Colors.blue[800] : Colors.orange[800],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Question number panel
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  _questions!.length,
                  (index) {
                    final isSelected = index == _currentQuestionIndex;
                    final hasAnswer = _questions![index].selectedAnswer != null;
                    final isTappable = _canNavigateToQuestion(index);
                    final isPartBQuestion = index >= 20;

                    // Part B questions are permanently locked after finishing.
                    final isLocked = isPartBQuestion && _partBFinished;

                    Color backgroundColor;
                    Color borderColor;
                    Color textColor;
                    double borderWidth = 1;

                    if (isLocked) {
                      backgroundColor = Colors.grey[200]!;
                      borderColor = Colors.grey[300]!;
                      textColor = Colors.grey[400]!;
                    } else if (isSelected) {
                      backgroundColor = Colors.blue[700]!;
                      borderColor = Colors.blue[700]!;
                      textColor = Colors.white;
                      borderWidth = 2;
                    } else if (!isTappable && isPartBQuestion) {
                      // Not tappable during Part B itself
                      backgroundColor = Colors.grey[200]!;
                      borderColor = Colors.grey[300]!;
                      textColor = Colors.grey[400]!;
                    } else if (hasAnswer) {
                      backgroundColor = Colors.green[50]!;
                      borderColor = Colors.green[300]!;
                      textColor = Colors.green[700]!;
                    } else {
                      backgroundColor = Colors.white;
                      borderColor = Colors.grey[300]!;
                      textColor = Colors.blue[900]!;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Material(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: isTappable && !isLocked
                              ? () => _navigateToQuestion(index)
                              : null,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: borderColor,
                                width: borderWidth,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: textColor,
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
              // Lock scrolling based on the current part of the exam
              physics: (_isPartB || _isReviewA)
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              onPageChanged: (index) {
                // This should only be called in Part A
                if (_isPartA) {
                  setState(() {
                    _currentQuestionIndex = index;
                  });
                }
              },
              // BUG FIX: Dynamically set item count to lock Part B
              itemCount: _isReviewA ? 20 : _questions!.length,
              itemBuilder: (context, index) {
                final question = _questions![index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (index >= 20 && index < 40)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Listening',
                                    style: TextStyle(
                                      color: Colors.orange[700],
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // This timer is now shown in the header
                                // Container(
                                //   padding: const EdgeInsets.symmetric(
                                //       horizontal: 10, vertical: 3),
                                //   decoration: BoxDecoration(
                                //     color: Colors.red[50],
                                //     borderRadius: BorderRadius.circular(6),
                                //   ),
                                //   child: Text(
                                //     'Q Timer: ${(_part2QuestionTimeLeft ~/ 60).toString().padLeft(2, '0')}:${(_part2QuestionTimeLeft % 60).toString().padLeft(2, '0')}',
                                //     style: TextStyle(
                                //       color: Colors.red[700],
                                //       fontSize: 13,
                                //       fontWeight: FontWeight.bold,
                                //     ),
                                //   ),
                                // ),
                                // const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _isAudioPlaying
                                            ? Icons.volume_up
                                            : Icons.volume_off,
                                        color: Colors.blue[700],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Audio will play automatically',
                                        style: TextStyle(
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
                      if (index >= 20 && index < 40)
                        Container(
                          padding: const EdgeInsets.all(18),
                          margin: const EdgeInsets.only(bottom: 28),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isAudioPlaying
                                    ? Icons.volume_up
                                    : Icons.volume_off,
                                color: Colors.blue[700],
                              ),
                              const SizedBox(width: 14),
                              Text(
                                _isAudioPlaying
                                    ? 'Playing audio...'
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
                          fontSize: 20,
                          color: Color(0xFF1E1E1E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 36),
                      ...question.options.asMap().entries.map((entry) {
                        final isSelected =
                            question.selectedAnswer == entry.value;
                        return GestureDetector(
                          onTap: (_isPartB && _isAudioPlaying)
                              ? null // Disable selection while audio is playing in Part B
                              : () {
                                  setState(() {
                                    _questions![index].selectedAnswer =
                                        entry.value;
                                  });
                                },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 18),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? Colors.blue[50] : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue[700]!
                                    : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
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
                                            : Colors.blue[900],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.blue[700]
                                          : const Color(0xFF1E1E1E),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 16,
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
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous button
                if ((_isPartA || _isReviewA) && _currentQuestionIndex > 0)
                  _buildNavButton(
                    icon: Icons.arrow_back,
                    label: 'Previous',
                    onPressed: () =>
                        _navigateToQuestion(_currentQuestionIndex - 1),
                    isPrimary: false,
                  )
                else
                  const SizedBox(width: 120), // Placeholder for alignment

                // Next/Submit button
                if ((_isPartA || _isReviewA) && _currentQuestionIndex < 19)
                  _buildNavButton(
                    icon: Icons.arrow_forward,
                    label: 'Next',
                    onPressed: () =>
                        _navigateToQuestion(_currentQuestionIndex + 1),
                  )
                else if (_isPartA && _currentQuestionIndex == 19)
                  _buildNavButton(
                    icon: Icons.send,
                    label: 'Finish Part 1',
                    onPressed: () => _showPart1FinishDialog(),
                  )
                else if (_isReviewA && _currentQuestionIndex == 19)
                  _buildNavButton(
                    icon: Icons.check,
                    label: 'Submit Exam',
                    onPressed: () => _showSubmitConfirmationDialog(),
                  )
                else if (_isPartB && _currentQuestionIndex < 39)
                  _buildNavButton(
                    icon: Icons.arrow_forward,
                    label: 'Next',
                    onPressed: _isAudioPlaying
                        ? null
                        : () => _moveToNextPart2Question(),
                  )
                else if (_isPartB && _currentQuestionIndex == 39)
                  _buildNavButton(
                    icon: Icons.check,
                    label: 'Finish Part 2',
                    onPressed: _isAudioPlaying ? null : () => _finishPart2(),
                  )
                else
                  const SizedBox(width: 120), // Placeholder for alignment
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Exit Exam?',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Exit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPart1FinishDialog() {
    if (!_isPart1Complete()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Part 1 Incomplete'),
          content: const Text(
              'Please answer all questions in Part 1 (1-20) before proceeding.'),
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Finish Part 1?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            'You are about to move to Part 2. You will not be able to return to Part 1 until you finish Part 2.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _moveToPart2();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Proceed'),
          ),
        ],
      ),
    );
  }

  void _showSubmitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Submit Exam?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to submit your answers?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _finishExam();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isPrimary = true,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.blue[700] : Colors.grey[100],
        foregroundColor: isPrimary ? Colors.white : Colors.blue[900],
        elevation: isPrimary ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
