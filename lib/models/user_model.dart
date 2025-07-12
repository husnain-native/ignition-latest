import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String? profileImage;
  final DateTime createdAt;
  final List<String> bookingHistory;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.profileImage,
    required this.createdAt,
    required this.bookingHistory,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      profileImage: json['profileImage'] as String?,
      createdAt:
          json['createdAt'] is String
              ? DateTime.parse(json['createdAt'] as String)
              : json['createdAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
              : json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
      bookingHistory:
          (json['bookingHistory'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'bookingHistory': bookingHistory.toList(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? profileImage,
    DateTime? createdAt,
    List<String>? bookingHistory,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      bookingHistory: bookingHistory ?? this.bookingHistory,
    );
  }
}
