class BookingModel {
  final String id;
  final String userId;
  final String spaceId;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final String status; // pending, confirmed, cancelled, completed
  final DateTime createdAt;
  final Map<String, dynamic>? additionalServices;

  BookingModel({
    required this.id,
    required this.userId,
    required this.spaceId,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.additionalServices,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      spaceId: json['spaceId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      additionalServices: json['additionalServices'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'spaceId': spaceId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'additionalServices': additionalServices,
    };
  }

  Duration get duration => endTime.difference(startTime);
}
