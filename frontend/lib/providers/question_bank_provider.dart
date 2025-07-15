import 'package:flutter/material.dart';
import '../models/question_bank.dart';
import '../models/mcq_question.dart';
import '../models/audio_question.dart';
import '../services/mock_exam_service.dart';
import '../config/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mock_exam.dart';

class QuestionBankProvider extends ChangeNotifier {
  final MockExamService _mockExamService = MockExamService();
  List<QuestionBank>? _questionBanks;
  bool _isLoading = false;
  String? _error;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;

  // Add mock exams storage and getter
  List<MockExam>? _mockExams;
  List<MockExam>? get mockExams => _mockExams;

  // Getters
  List<QuestionBank>? get questionBanks => _questionBanks;
  List<QuestionBank>? _questionAudioBanks;
  List<QuestionBank>? get questionAudioBanks => _questionAudioBanks;

  bool _isAudioLoading = false;
  bool _isMockExamsLoading = false;
  String? _audioError;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  bool get isAudioLoading => _isAudioLoading;
  String? get audioError => _audioError;
  bool get isMockExamsLoading => _isMockExamsLoading;

  Future<void> loadQuestionBanks() async {
    if (_isLoading) return; // Prevent multiple simultaneous loads

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _questionBanks = await _mockExamService.getQuestionBanks();
      _error = null;
    } catch (e) {
      _error = 'Failed to load question banks: ${e.toString()}';
      _questionBanks = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAudioQuestionBanks() async {
    if (_isAudioLoading) return; // Prevent multiple simultaneous loads

    _isAudioLoading = true;
    _audioError = null;
    notifyListeners();

    try {
      final audioBank = await _mockExamService.getAudioQuestionsBanks();
      _questionAudioBanks = audioBank;
      print(_questionAudioBanks);
      _audioError = null;
    } catch (e) {
      _audioError = 'Failed to load audio question banks: ${e.toString()}';
      _questionAudioBanks = null;
    } finally {
      _isAudioLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMockExams() async {
    if (_isMockExamsLoading) return; // Prevent multiple simultaneous loads
    _isMockExamsLoading = true;
    _error = null;
    notifyListeners();
    try {
      final mockExams = await _mockExamService.getMockExams();
      _mockExams = mockExams;
      print('Loaded mock exams: ${_mockExams}');
      _error = null;
    } catch (e) {
      _error = 'Failed to load mock exams: ${e.toString()}';
      _mockExams = null;
    } finally {
      _isMockExamsLoading = false;
      notifyListeners();
    }
  }

  Future<void> createQuestionBank(
      String title, List<MCQQuestion> questions) async {
    if (_isCreating) return; // Prevent multiple simultaneous creates
    if (title.trim().isEmpty) {
      _error = 'Title cannot be empty';
      notifyListeners();
      return;
    }
    if (questions.length != AppConstants.questionsCount) {
      _error =
          'Invalid number of questions. Expected ${AppConstants.requiredQuestionsCount}, got ${questions.length}';
      notifyListeners();
      return;
    }

    _isCreating = true;
    _error = null;
    notifyListeners();

    try {
      await _mockExamService.createQuestionBank(title, questions);
      await loadQuestionBanks(); // Reload the question banks after creating
      _error = null;
    } catch (e) {
      _error = 'Failed to create question bank: ${e.toString()}';
      rethrow;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  Future<void> createAudioQuestionBank(
      String title, List<AudioQuestion> questions) async {
    if (_isCreating) return; // Prevent multiple simultaneous creates
    if (title.trim().isEmpty) {
      _error = 'Title cannot be empty';
      notifyListeners();
      return;
    }
    if (questions.length != AppConstants.questionsCount) {
      _error =
          'Invalid number of questions. Expected 2${AppConstants.requiredQuestionsCount}, got 2${questions.length}';
      notifyListeners();
      return;
    }

    _isCreating = true;
    _error = null;
    notifyListeners();

    try {
      await _mockExamService.createAudioQuestionBank(title, questions);
      await loadQuestionBanks(); // Reload the question banks after creating
      _error = null;
    } catch (e) {
      _error = 'Failed to create audio question bank: 2${e.toString()}';
      rethrow;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  Future<void> updateQuestionBank(
      String bankId, String title, List<MCQQuestion> questions) async {
    if (_isUpdating) return; // Prevent multiple simultaneous updates
    if (title.trim().isEmpty) {
      _error = 'Title cannot be empty';
      notifyListeners();
      return;
    }
    if (questions.length != AppConstants.requiredQuestionsCount) {
      _error =
          'Invalid number of questions. Expected ${AppConstants.requiredQuestionsCount}, got ${questions.length}';
      notifyListeners();
      return;
    }

    _isUpdating = true;
    _error = null;
    notifyListeners();

    try {
      await _mockExamService.updateQuestionBank(bankId, title, questions);
      await loadQuestionBanks(); // Reload the list
      _error = null;
    } catch (e) {
      _error = 'Failed to update question bank: ${e.toString()}';
      rethrow;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<void> deleteQuestionBank(String bankId) async {
    if (_isDeleting) return; // Prevent multiple simultaneous deletes
    if (bankId.isEmpty) {
      _error = 'Invalid question bank ID';
      notifyListeners();
      return;
    }

    _isDeleting = true;
    _error = null;
    notifyListeners();

    try {
      await _mockExamService.deleteQuestionBank(bankId);
      await loadQuestionBanks(); // Reload the list
      _error = null;
    } catch (e) {
      _error = 'Failed to delete question bank: ${e.toString()}';
      rethrow;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  // Helper method to clear errors
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
