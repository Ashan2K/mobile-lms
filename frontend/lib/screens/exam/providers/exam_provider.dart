import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../models/exam_question.dart';
import '../../../services/exam_service.dart';

class ExamProvider extends ChangeNotifier {
  final ExamService _examService = ExamService();
  List<ExamQuestion>? _questions;
  AudioPlayer? _audioPlayer;
  int _currentQuestionIndex = 0;
  bool _part1Completed = false;
  bool _part2Completed = false;
  int _audioPlayCount = 0;
  bool _isAudioPlaying = false;
  bool _isLoading = true;
  final bool _tempDisableAudio = true;

  // Getters
  List<ExamQuestion>? get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get part1Completed => _part1Completed;
  bool get part2Completed => _part2Completed;
  bool get isAudioPlaying => _isAudioPlaying;
  bool get isLoading => _isLoading;
  int get audioPlayCount => _audioPlayCount;

  Future<void> initAudioPlayer() async {
    try {
      _audioPlayer = AudioPlayer();
      _audioPlayer?.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _onAudioComplete();
        }
        _isAudioPlaying = state.playing;
        notifyListeners();
      });
    } catch (e) {
      print('Error initializing audio player: $e');
    }
  }

  Future<void> loadQuestions() async {
    try {
      _questions = await _examService.getExamQuestions();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  bool canNavigateToQuestion(int index) {
    if (index < 20) {
      return !_isAudioPlaying;
    } else {
      return isPart1Complete() && !_isAudioPlaying;
    }
  }

  bool isPart1Complete() {
    if (_questions == null) return false;
    final part1Questions = _questions!.sublist(0, 20);
    final allAnswered = part1Questions.every((q) => q.selectedAnswer != null);
    if (allAnswered && !_part1Completed) {
      _part1Completed = true;
      notifyListeners();
    }
    return allAnswered;
  }

  Future<void> navigateToQuestion(int index) async {
    if (!canNavigateToQuestion(index)) return;

    _currentQuestionIndex = index;
    notifyListeners();

    if (index >= 20 && index < 40 && !_part2Completed) {
      _audioPlayCount = 0;
      if (_questions![index].audioUrl != null) {
        await playAudio(_questions![index].audioUrl!);
      }
    }
  }

  Future<void> playAudio(String audioPath) async {
    if (_tempDisableAudio) {
      _isAudioPlaying = true;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 3));
      _onAudioComplete();
      return;
    }

    try {
      if (_audioPlayer == null) {
        await initAudioPlayer();
      }

      _isAudioPlaying = true;
      notifyListeners();
      await _audioPlayer?.setAsset(audioPath);
      await _audioPlayer?.play();
    } catch (e) {
      _isAudioPlaying = false;
      notifyListeners();
      rethrow;
    }
  }

  void _onAudioComplete() {
    if (_currentQuestionIndex >= 20 && _currentQuestionIndex < 40) {
      _audioPlayCount++;
      if (_audioPlayCount < 3) {
        playAudio(_questions![_currentQuestionIndex].audioUrl!);
      } else {
        _audioPlayCount = 0;
        _isAudioPlaying = false;
        if (_currentQuestionIndex < 39) {
          navigateToQuestion(_currentQuestionIndex + 1);
        } else {
          _part2Completed = true;
        }
        notifyListeners();
      }
    }
  }

  void selectAnswer(String answer) {
    if (_questions == null) return;
    _questions![_currentQuestionIndex].selectedAnswer = answer;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }
}
