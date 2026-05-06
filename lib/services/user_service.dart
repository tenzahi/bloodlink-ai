import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sauvegarde ou met à jour un utilisateur
  Future<void> saveUser(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
  }

  // Récupère un utilisateur par son ID
  Future<UserModel?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) return UserModel.fromMap(doc.data()!, doc.id);
    return null;
  }

  // Change le rôle (donor <-> receiver)
  // ✅ Corrigé
  Future<void> switchRole(String userId, String newRole) async {
    await _db.collection('users').doc(userId).update({
      'role': newRole,
      'isAvailable': newRole == 'donor', // true si donor, false si receiver
    });
  }
  Future<void> updateAvailability(String userId, bool value) async {
    await _db.collection('users').doc(userId).update({
      'isAvailable': value,
    });
  }
  // Appelé quand le donneur clique "J'ai donné mon sang"
  Future<void> markAsDonated(String userId) async {
    await _db.collection('users').doc(userId).update({
      'isAvailable': false,
      'lastDonationDate': Timestamp.now(),
    });
  }

  // Vérifie et remet disponible si 3 mois sont passés
  Future<void> checkAndUpdateAvailability(String userId) async {
    final user = await getUser(userId);
    if (user == null || user.isAvailable) return;

    if (user.lastDonationDate != null) {
      final threeMonthsLater =
      user.lastDonationDate!.add(const Duration(days: 90));
      if (DateTime.now().isAfter(threeMonthsLater)) {
        await _db.collection('users').doc(userId).update({
          'isAvailable': true,
        });
      }
    }
  }

  // Recherche donneurs par groupe sanguin
  Stream<List<UserModel>> searchDonors(String bloodType) {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'donor')
        .where('isAvailable', isEqualTo: true)
        .where('bloodType', isEqualTo: bloodType)
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList());
  }
}