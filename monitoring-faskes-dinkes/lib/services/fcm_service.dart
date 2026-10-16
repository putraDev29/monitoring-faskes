import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '/services/local_notification_service.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static const String baseUrl = "http://192.168.1.12:8000/api";

  Future<void> initFCM(int userId) async {
    // permission
    await _messaging.requestPermission();

    // token
    String? token = await _messaging.getToken();
    print("FCM TOKEN: $token");

    if (token != null) {
      await sendFcmToken(token, userId);
    }

    // FOREGROUND
    FirebaseMessaging.onMessage.listen((message) {
      print("RAW DATA: ${message.data}");
      print("NOTIF: ${message.notification}");

      LocalNotificationService.showNotification(message);
    });

    // CLICK NOTIF
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("NOTIF DIKLIK");
    });
  }

  static Future<bool> sendFcmToken(String token, int userId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/save-fcm-token"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json", // 🔥 penting supaya tidak redirect HTML
        },
        body: jsonEncode({"user_id": userId, "fcm_token": token}),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("ERROR SEND FCM TOKEN: $e");
      return false;
    }
  }
}
