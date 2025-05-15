class CourseModel {
  String courseName;
  String courseCode;
  String description;
  String status;
  String schedule;
  DateTime startDate;
  double price;
  DateTime? creatDate;

  CourseModel({
    required this.courseName,
    required this.courseCode,
    required this.description,
    required this.status,
    required this.schedule,
    required this.startDate,
    required this.price,
    this.creatDate,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
        courseName: json['courseName'],
        courseCode: json['courseCode'],
        description: json['description'],
        status: json['status'],
        schedule: json['schedule'],
        startDate: DateTime.parse(json['startDate']),
        price: double.parse(json['price'].toString()));
  }

  Map<String, dynamic> toJson() {
    return {
      'courseName': courseName,
      'courseCode': courseCode,
      'description': description,
      'status': status,
      'schedule': schedule,
      'startDate': startDate.toIso8601String(),
      'price': price,
      'createdAt': creatDate?.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'courseName': courseName,
      'courseCode': courseCode,
      'description': description,
      'status': status,
      'schedule': schedule,
      'startDate': startDate.toIso8601String(),
      'price': price,
    };
  }
}
