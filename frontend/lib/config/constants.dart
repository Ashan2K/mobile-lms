class AppConstants {
  // Set this to true for development/testing with fewer questions
  static const bool isDevelopment = false;

  // Number of questions required for a question bank
  static const int requiredQuestionsCount = 20;

  // Number of questions to use in development mode
  static const int developmentQuestionsCount = 3;

  // Get the current question count based on environment
  static int get questionsCount =>
      isDevelopment ? developmentQuestionsCount : requiredQuestionsCount;
}
