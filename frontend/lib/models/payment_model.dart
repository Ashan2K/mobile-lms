class PaymentModel {
  final String userId;
  final String courseId;
  final String month; // Format: YYYY-MM
  final double amount;
  final String status; // e.g., 'pending', 'completed', 'failed'
  final DateTime? paidAt;

  PaymentModel({
    required this.userId,
    required this.courseId,
    required this.month,
    required this.amount,
    required this.status,
    this.paidAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      userId: json['userId'] as String,
      courseId: json['courseId'] as String,
      month: json['month'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'courseId': courseId,
      'month': month,
      'amount': amount,
      'status': status,
      'paidAt': paidAt?.toIso8601String(),
    };
  }
}
