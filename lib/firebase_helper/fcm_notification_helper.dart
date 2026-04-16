import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:spot/services/configuration.dart';
import '../core/utils.dart';

class FcmNotificationHelper {
  static final instance = FcmNotificationHelper._internal();
  FcmNotificationHelper._internal();

  /// Request notification permissions from user
  static Future<void> requestNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // print('Permission: ${settings.authorizationStatus}');
  }

  /// Initialize FCM: request permissions, get token, and register
  Future<void> initFcm() async {
    await requestNotificationPermissions();

    final fcmToken = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $fcmToken');

    await registerFcmTokenToServer();
  }

  Future<void> registerFcmTokenToServer() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final deviceId = await CommonFunctions.getDeviceId();
      final userData = await CommonFunctions.getLoginUser();
      final authToken = userData['tToken'];

      final url = Uri.parse('${Configuration.baseURL}saveFcmToken');

      if (fcmToken != null && deviceId != null && authToken != null) {
        final response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'fcmToken': fcmToken,
            'deviceId': deviceId,
          }),
        );

        // print("fcmToken $fcmToken =====deviceId========$deviceId");
        // print("FCM Token Registered: ${response.statusCode} - ${response.body}");
      } else {
        // print("Missing token/device/user info");
      }
    } catch (e) {
      // print("error registering FCM token: $e");
    }
  }

  // Future<void> sendFCMPush({
  //   required String fcmToken,
  //   required String title,
  //   required String body,
  // }) async {
  //   final jsonCredentials = await rootBundle.loadString('assets/spot-32b4e-firebase-adminsdk-fbsvc-a89e3bb5d0.json');
  //   final serviceAccount = ServiceAccountCredentials.fromJson(jsonCredentials);
  //
  //   final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
  //
  //   final authClient = await clientViaServiceAccount(serviceAccount, scopes);
  //
  //   const projectId = 'spot-32b4e';
  //   final url = Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send');
  //
  //   final messagePayload = {
  //     "message": {
  //       "token": fcmToken,
  //       "notification": {
  //         "title": title,
  //         "body": body,
  //       },
  //       "android": {
  //         "priority": "high",
  //       },
  //       "apns": {
  //         "headers": {
  //           "apns-priority": "10",
  //         }
  //       },
  //     }
  //   };
  //
  //   final response = await authClient.post(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode(messagePayload),
  //   );
  //
  //   print('FCM Response: ${response.statusCode}');
  //   print(response.body);
  // }
  Future<void> sendFCMPush({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    final jsonCredentials = await rootBundle.loadString(
        'assets/spot-32b4e-firebase-adminsdk-fbsvc-a89e3bb5d0.json');
    final serviceAccount = ServiceAccountCredentials.fromJson(jsonCredentials);

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final authClient = await clientViaServiceAccount(serviceAccount, scopes);

    const projectId = 'spot-32b4e';
    final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send');

    final messagePayload = {
      "message": {
        "token": fcmToken,
        "notification": {
          "title": title,
          "body": body,
        },
        "android": {
          "priority": "high",
        },
        "apns": {
          "headers": {
            "apns-priority": "10",
          }
        },
        if (data != null) "data": data, // <-- ADD THIS LINE
      }
    };

    final response = await authClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(messagePayload),
    );

    // print('FCM Response: ${response.statusCode}');
  }
}
