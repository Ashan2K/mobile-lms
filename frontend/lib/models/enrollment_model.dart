class EnrollmentModel {
  final String userId;
  final String courseId;
  final List<String> paidMonths;
  final DateTime? enrolledAt; // <-- Add this

  EnrollmentModel({
    required this.userId,
    required this.courseId,
    required this.paidMonths,
    this.enrolledAt, // <-- Add this
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseEnrolledAt(dynamic value) {
      if (value == null) return null;
      if (value is String) return DateTime.tryParse(value);
      if (value is Map && value.containsKey('_seconds')) {
        int seconds = value['_seconds'] as int;
        int nanoseconds = value['_nanoseconds'] as int? ?? 0;
        return DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanoseconds / 1000000).round(),
        );
      }
      return null;
    }

    return EnrollmentModel(
      userId: json['userId'] as String,
      courseId: json['courseId'] as String,
      paidMonths: (json['paidMonths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      enrolledAt: parseEnrolledAt(json['enrolledAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'courseId': courseId,
      'paidMonths': paidMonths,
    };
  }
}
