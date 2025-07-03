import 'package:hive/hive.dart';
part 'booking_model.g.dart';

class BookingModel {
  final String id;
  final String userId;
  final String spaceId;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final String status; // pending, booked, rejected
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

@HiveType(typeId: 1)
class BookingRequest {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  final String userName;
  @HiveField(3)
  final String email;
  @HiveField(4)
  final String phone;
  @HiveField(5)
  final String branch;
  @HiveField(6)
  final String date;
  @HiveField(7)
  final String timeSlot;
  @HiveField(8)
  final String status; // pending, booked, rejected

  BookingRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.email,
    required this.phone,
    required this.branch,
    required this.date,
    required this.timeSlot,
    required this.status,
  });

  factory BookingRequest.fromMap(Map<String, dynamic> map, String id) {
    String status = map['status'] ?? 'pending';
    if (status == 'accepted') status = 'booked';
    if (status == 'denied') status = 'rejected';
    return BookingRequest(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      branch: map['branch'] ?? '',
      date: map['date'] ?? '',
      timeSlot: map['timeSlot'] ?? '',
      status: status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'email': email,
      'phone': phone,
      'branch': branch,
      'date': date,
      'timeSlot': timeSlot,
      'status': status,
    };
  }
}
