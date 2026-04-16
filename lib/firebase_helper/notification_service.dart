import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static Future<void> requestPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // print('Notification permission status: ${settings.authorizationStatus}');
  }
}
