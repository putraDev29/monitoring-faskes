import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ================= INIT =================
  static Future init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(initSettings);

    final androidPlatform = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // CHANNEL NORMAL SOUND
    const statusChannel = AndroidNotificationChannel(
      'channel_id_sound_v2',
      'channel_name_sound_v2',
      description: 'Channel normal sound',
      importance: Importance.max,
      playSound: true,
    );

    await androidPlatform?.createNotificationChannel(statusChannel);
  }

  // ================= SHOW NOTIF =================
  static Future showNotification(RemoteMessage message) async {

    AndroidNotificationDetails androidDetails;

      androidDetails = const AndroidNotificationDetails(
        'channel_id_sound_v2',
        'channel_name_sound_v2',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        // icon: 'ic_notification', // ✅ TAMBAHAN
      );
  
    final details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'Notifikasi',
      message.notification?.body ?? '',
      details,
    );
  }
}
