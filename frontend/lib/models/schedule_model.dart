class ScheduleModel {
  final String? id;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final String classType; // 'Online' or 'Physical'
  final String? zoomLink;
  final String courseId;
  final String courseName;
  final int currentStudents;
  final DateTime createdAt;
  final DateTime updatedAt;

  ScheduleModel({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.classType,
    this.zoomLink,
    required this.courseId,
    required this.courseName,
    this.currentStudents = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    // Handle Firestore timestamp format for date
    DateTime parseDate(dynamic dateValue) {
      if (dateValue is Map<String, dynamic> &&
          dateValue.containsKey('_seconds')) {
        // Firestore timestamp format
        final seconds = dateValue['_seconds'] as int;
        final nanoseconds = dateValue['_nanoseconds'] as int? ?? 0;
        return DateTime.fromMillisecondsSinceEpoch(
            seconds * 1000 + (nanoseconds / 1000000).round());
      } else if (dateValue is String) {
        // ISO string format
        return DateTime.parse(dateValue);
      } else {
        throw FormatException('Invalid date format: $dateValue');
      }
    }

    return ScheduleModel(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: parseDate(json['date']),
      time: json['time'] ?? '',
      classType: json['classType'] ?? 'Physical',
      zoomLink: json['zoomLink'],
      courseId: json['courseId'] ?? '',
      courseName: json['courseName'] ?? '',
      currentStudents: json['currentStudents'] ?? 0,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'time': time,
      'classType': classType,
      if (zoomLink != null) 'zoomLink': zoomLink,
      'courseId': courseId,
      'courseName': courseName,
      'currentStudents': currentStudents,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ScheduleModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? time,
    String? classType,
    String? zoomLink,
    String? courseId,
    String? courseName,
    int? currentStudents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      classType: classType ?? this.classType,
      zoomLink: zoomLink ?? this.zoomLink,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      currentStudents: currentStudents ?? this.currentStudents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ScheduleModel(id: $id, title: $title, date: $date, time: $time, classType: $classType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScheduleModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
