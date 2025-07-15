class MockExam {
  final String id;
  final String title;
  final String description;
  final String bankId;
  final String audioBankId;
  final String visibility;
  final DateTime createdAt;

  MockExam({
    required this.id,
    required this.title,
    required this.description,
    required this.bankId,
    required this.audioBankId,
    required this.visibility,
    required this.createdAt,
  });

  factory MockExam.fromJson(Map<String, dynamic> json) {
    DateTime parseCreatedAt(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) return DateTime.parse(value);
      if (value is Map && value.containsKey('_seconds')) {
        int seconds = value['_seconds'] as int;
        int nanoseconds = value['_nanoseconds'] as int? ?? 0;
        return DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanoseconds / 1000000).round(),
        );
      }
      return DateTime.now();
    }

    return MockExam(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      bankId: json['bankId'] ?? '',
      audioBankId: json['audioBankId'] ?? '',
      visibility: json['visibility'] ?? '',
      createdAt: parseCreatedAt(json['createdAt']),
    );
  }
}
