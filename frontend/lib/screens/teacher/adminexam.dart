import 'package:flutter/material.dart';
import 'package:frontend/screens/teacher/question_controller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../controllers/question_controller.dart';
import '../../models/question.dart';
import 'question_list_screen.dart';

class AdminScreen extends StatelessWidget {
  final String quizCategory;
  AdminScreen({super.key, required this.quizCategory}) {
    Get.put(QuestionController());
  }
  final QuestionController questionController = Get.put(QuestionController());

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      questionController.setQuestionImage(File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        title: Text(
          "Add Questions to $quizCategory",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list, color: Colors.white),
            onPressed: () {
              Get.to(() => QuestionListScreen(quizCategory: quizCategory));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Question ${questionController.questionCount + 1}/30",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: questionController.questionController,
                      decoration: InputDecoration(
                        labelText: "Question",
                        labelStyle: const TextStyle(
                          color: Color(0xFF1E3A8A),
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFF1E3A8A)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFF1E3A8A)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFF1E3A8A)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Image Selection Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Question Image (Optional)",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Obx(() => questionController.questionImage.value !=
                                  null
                              ? Stack(
                                  children: [
                                    Container(
                                      height: 150,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: FileImage(questionController
                                              .questionImage.value!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Colors.white),
                                        onPressed: () => questionController
                                            .clearQuestionImage(),
                                        style: IconButton.styleFrom(
                                          backgroundColor:
                                              Colors.black.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(
                                  height: 150,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.blue[300]!),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image,
                                          size: 48, color: Colors.blue[300]),
                                      const SizedBox(height: 8),
                                      Text(
                                        "No image selected",
                                        style: TextStyle(
                                          color: Colors.blue[300],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          const SizedBox(height: 1),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.add_photo_alternate),
                              label: const Text("Select Image"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Options:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (var i = 0; i < 4; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller:
                                    questionController.optionControllers[i],
                                decoration: InputDecoration(
                                  labelText: "Option ${i + 1}",
                                  labelStyle: const TextStyle(
                                    color: Color(0xFF1E3A8A),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF1E3A8A)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF1E3A8A)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF1E3A8A)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Obx(() => Radio<int>(
                                  value: i,
                                  groupValue:
                                      questionController.selectedAnswer.value,
                                  onChanged: (value) {
                                    questionController.selectedAnswer.value =
                                        value!;
                                  },
                                )),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (questionController
                                  .questionController.text.isEmpty ||
                              questionController.optionControllers.any(
                                  (controller) => controller.text.isEmpty) ||
                              questionController.selectedAnswer.value == -1) {
                            Get.snackbar(
                              "Required",
                              "All Fields are Required",
                              backgroundColor: Colors.red[100],
                              colorText: Colors.red[900],
                            );
                            return;
                          }

                          final String questionText =
                              questionController.questionController.text;
                          final List<String> options = questionController
                              .optionControllers
                              .map((controller) => controller.text)
                              .toList();
                          final int correctAnswer =
                              questionController.selectedAnswer.value;

                          final Question newQuestion = Question(
                            category: quizCategory,
                            id: DateTime.now().microsecondsSinceEpoch,
                            questions: questionText,
                            options: options,
                            answer: correctAnswer,
                            imagePath:
                                questionController.questionImage.value?.path,
                          );

                          await questionController
                              .saveQuestionToSharedPrefrences(newQuestion);
                          questionController.incrementQuestionCount();

                          if (questionController.questionCount >= 30) {
                            Get.snackbar(
                              "Complete",
                              "All 30 questions have been added!",
                              backgroundColor: Colors.green[100],
                              colorText: Colors.green[900],
                            );
                            return;
                          }

                          Get.snackbar(
                            "Added",
                            "Question ${questionController.questionCount}/30 Added",
                            backgroundColor: Colors.green[100],
                            colorText: Colors.green[900],
                          );
                          questionController.questionController.clear();
                          questionController.optionControllers
                              .forEach((element) {
                            element.clear();
                          });
                          questionController.selectedAnswer.value = -1;
                          questionController.clearQuestionImage();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Add Question",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
