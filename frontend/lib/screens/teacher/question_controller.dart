import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../models/question.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class QuestionController extends GetxController {
  final TextEditingController questionController = TextEditingController();
  final List<TextEditingController> optionControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final RxInt selectedAnswer = (-1).obs;
  final RxInt questionCount = 0.obs;
  final Rx<File?> questionImage = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    loadQuestionCount();
  }

  void setQuestionImage(File image) {
    questionImage.value = image;
  }

  void clearQuestionImage() {
    questionImage.value = null;
  }

  void incrementQuestionCount() {
    questionCount.value++;
  }

  Future<void> loadQuestionCount() async {
    final prefs = await SharedPreferences.getInstance();
    questionCount.value = prefs.getInt('questionCount') ?? 0;
  }

  Future<void> saveQuestionToSharedPrefrences(Question question) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> questions = prefs.getStringList('questions') ?? [];
    questions.add(jsonEncode(question.toJson()));
    await prefs.setStringList('questions', questions);
    await prefs.setInt('questionCount', questionCount.value);
  }

  @override
  void onClose() {
    questionController.dispose();
    for (var controller in optionControllers) {
      controller.dispose();
    }
    super.onClose();
  }
}
