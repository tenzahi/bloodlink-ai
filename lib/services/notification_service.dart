import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _local =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Demande permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configure notifications locales
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Notification quand app en foreground
    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
    });

    // Notification quand app en background et cliquée
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // navigation si besoin
    });
  }

  // Affiche notification locale
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'bloodlink_channel',
        'BloodLink Notifications',
        channelDescription: 'Notifications BloodLink AI',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'BloodLink AI',
      message.notification?.body ?? '',
      details,
    );
  }

  // Sauvegarde le token FCM dans Firestore
  static Future<void> saveToken(String userId) async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'fcmToken': token});
      }

      // Met à jour si token change
      _messaging.onTokenRefresh.listen((newToken) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'fcmToken': newToken});
      });
    } catch (e) {
      print('Erreur saveToken: $e');
    }
  }

  // Notifie tous les receveurs compatibles
  static Future<void> notifyReceivers({
    required String bloodType,
    required String donorName,
  }) async {
    try {
      // Groupes compatibles avec ce donneur
      final compatible = _compatibleReceivers(bloodType);

      for (final group in compatible) {
        final receivers = await FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'receiver')
            .where('bloodType', isEqualTo: group)
            .get();

        for (final doc in receivers.docs) {
          final token = doc.data()['fcmToken'];
          if (token != null && token.toString().isNotEmpty) {
            // Crée la notification dans Firestore
            // La Cloud Function va l'envoyer
            await FirebaseFirestore.instance
                .collection('notifications')
                .add({
              'token': token,
              'title': '🩸 Donneur disponible !',
              'body':
              '$donorName (groupe $bloodType) est disponible pour donner son sang.',
              'bloodType': bloodType,
              'donorName': donorName,
              'createdAt': DateTime.now().toIso8601String(),
              'sent': false,
            });
          }
        }
      }
    } catch (e) {
      print('Erreur notifyReceivers: $e');
    }
  }

  // Quels receveurs peuvent recevoir ce groupe sanguin
  static List<String> _compatibleReceivers(String donorGroup) {
    const map = {
      'O-':  ['O-', 'O+', 'A-', 'A+', 'B-', 'B+', 'AB-', 'AB+'],
      'O+':  ['O+', 'A+', 'B+', 'AB+'],
      'A-':  ['A-', 'A+', 'AB-', 'AB+'],
      'A+':  ['A+', 'AB+'],
      'B-':  ['B-', 'B+', 'AB-', 'AB+'],
      'B+':  ['B+', 'AB+'],
      'AB-': ['AB-', 'AB+'],
      'AB+': ['AB+'],
    };
    return map[donorGroup] ?? [donorGroup];
  }
}