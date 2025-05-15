import 'package:flutter/material.dart';
import '../models/question_bank.dart';
import '../models/mcq_question.dart';
import '../services/mock_exam_service.dart';
import '../config/constants.dart';

class QuestionBankProvider extends ChangeNotifier {
  final MockExamService _mockExamService = MockExamService();
  List<QuestionBank>? _questionBanks;
  bool _isLoading = false;
  String? _error;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;

  // Getters
  List<QuestionBank>? get questionBanks => _questionBanks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;

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
