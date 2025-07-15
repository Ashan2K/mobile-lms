import 'dart:convert';
import 'package:frontend/models/mock_exam.dart';
import 'package:frontend/services/base_url.dart';
import 'package:http/http.dart' as http;
import '../models/mcq_question.dart';
import '../models/question_bank.dart';
import '../config/constants.dart';
import '../models/audio_question.dart';

class MockExamService {
  Future<List<QuestionBank>> getQuestionBanks() async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/get-question-set'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final banksList = data as List;
        return banksList.map((b) => QuestionBank.fromJson(b)).toList();
      } else {
        throw Exception('Failed to fetch question banks: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching question banks: $e');
    }
  }

  Future<String> createQuestionBank(
      String title, List<MCQQuestion> questions) async {
    try {
      if (questions.length != AppConstants.questionsCount) {
        throw Exception(
          'Invalid number of questions. Expected ${AppConstants.requiredQuestionsCount}, got ${questions.length}',
        );
      }

      final response = await http.post(
        Uri.parse('$url/api/create-questions'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'questions': questions.map((q) => q.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'];
      } else {
        throw Exception('Failed to create question bank: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating question bank: $e');
    }
  }

  Future<String> createAudioQuestionBank(
      String title, List<AudioQuestion> questions) async {
    try {
      if (questions.length != AppConstants.questionsCount) {
        throw Exception(
          'Invalid number of questions. Expected 2${AppConstants.requiredQuestionsCount}, got 2${questions.length}',
        );
      }

      final response = await http.post(
        Uri.parse('$url/api/create-audio-questions'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'type': 'audio',
          'questions': questions.map((q) => q.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'];
      } else {
        throw Exception(
            'Failed to create audio question bank: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating audio question bank: $e');
    }
  }

  Future<QuestionBank> getMcqQuestionBank(String bankId) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/question-banks/$bankId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return QuestionBank.fromJson(data);
      } else {
        throw Exception('Failed to fetch question bank: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching question bank: $e');
    }
  }

  Future<QuestionBank> getAudioQuestionBank(String bankId) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/audio-question-banks/$bankId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return QuestionBank.fromJson(data);
      } else {
        throw Exception(
            'Failed to fetch audio question bank: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching audio question bank: $e');
    }
  }

  Future<void> updateQuestionBank(
      String bankId, String title, List<MCQQuestion> questions) async {
    try {
      final response = await http.put(
        Uri.parse('$url/api/question-banks/$bankId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'questions': questions.map((q) => q.toJson()).toList(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update question bank: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating question bank: $e');
    }
  }

  Future<void> deleteQuestionBank(String bankId) async {
    try {
      final response = await http.delete(
        Uri.parse('$url/api/question-banks/$bankId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete question bank: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting question bank: $e');
    }
  }

  Future<List<QuestionBank>> getAudioQuestionsBanks() async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/get-audio-question-set'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final banksList = data as List;
        return banksList.map((b) => QuestionBank.fromJson(b)).toList();
      } else {
        throw Exception(
            'Failed to fetch audio questions bank: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching audio questions bank: $e');
    }
  }

  Future<String> createMockExam(String title, String description, String bankId,
      String audioBankId, String visibility) async {
    try {
      print('Creating mock exam with:'
          '\nTitle: $title'
          '\nDescription: $description'
          '\nMCQ Bank ID: $bankId'
          '\nAudio Bank ID: $audioBankId'
          '\nVisibility: $visibility');
      final response = await http.post(
        Uri.parse('$url/api/create-mock-exam'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'bankId': bankId,
          'audioBankId': audioBankId,
          'visibility': visibility,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'];
      } else {
        throw Exception('Failed to create mock exam: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating mock exam: $e');
    }
  }

  Future<List<MockExam>> getMockExams() async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/get-mock-exams'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final banksList = data as List;
        return banksList.map((b) => MockExam.fromJson(b)).toList();
      } else {
        throw Exception('Failed to fetch mock exams: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching mock exams: $e');
    }
  }
}
