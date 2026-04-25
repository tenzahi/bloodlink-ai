import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;        // ← nouveau
  final String bloodType;
  final String role;
  final bool isAvailable;
  final DateTime? lastDonationDate;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.bloodType,
    required this.role,
    required this.isAvailable,
    this.lastDonationDate,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'phone': phone,
    'bloodType': bloodType,
    'role': role,
    'isAvailable': isAvailable,
    'lastDonationDate': lastDonationDate != null
        ? Timestamp.fromDate(lastDonationDate!)
        : null,
  };

  factory UserModel.fromMap(Map<String, dynamic> map, String id) => UserModel(
    id: id,
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    phone: map['phone'] ?? '',
    bloodType: map['bloodType'] ?? 'A+',
    role: map['role'] ?? 'receiver',
    isAvailable: map['isAvailable'] ?? false,
    lastDonationDate: map['lastDonationDate'] != null
        ? (map['lastDonationDate'] as Timestamp).toDate()
        : null,
  );
}