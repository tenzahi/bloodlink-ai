class UserModel {
  String id;
  String name;
  String email;
  String bloodType;
  String role; // donor / receiver
  bool isAvailable;
  String? lastDonationDate;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.bloodType,
    required this.role,
    required this.isAvailable,
    this.lastDonationDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'bloodType': bloodType,
      'role': role,
      'isAvailable': isAvailable,
      'lastDonationDate': lastDonationDate,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      bloodType: map['bloodType'],
      role: map['role'],
      isAvailable: map['isAvailable'],
      lastDonationDate: map['lastDonationDate'],
    );
  }
}