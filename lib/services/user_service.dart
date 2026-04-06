import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUser(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.id)
        .set(user.toMap());
  }
  Stream<List<UserModel>> getDonors() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'donor')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .where((user) => isEligible(user.lastDonationDate)) // ✅ ici
          .toList();
    });
  }
  Stream<List<UserModel>> getDonorsByBlood(String blood) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'donor')
        .where('bloodType', isEqualTo: blood)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .where((user) => isEligible(user.lastDonationDate)) // ✅ ici
          .toList();
    });
  }
  Future<void> updateAvailability(String userId, bool status) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({
      'isAvailable': status,
      'lastDonationDate': DateTime.now(),
    });
  }
  bool isEligible(DateTime? lastDonation) {
    if (lastDonation == null) return true;

    final diff = DateTime.now().difference(lastDonation).inDays;
    return diff >= 90;
  }
  Future<void> updateRole(String userId, String newRole) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({
      'role': newRole,
    });
  }
  Future<UserModel?> getUser(String userId) async {
    var doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

}