import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:monitoring_faskes_dinkes/pages/login_page.dart';
import 'package:monitoring_faskes_dinkes/services/local_notification_service.dart';
import 'package:monitoring_faskes_dinkes/utils/AuthWrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  // FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  // await LocalNotificationService.init();

  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   LocalNotificationService.showNotification(message);
  // });

 await initializeDateFormatting('id_ID', null); // 🔥 WAJIB
  runApp(MyApp());
}

// Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hospital Dashboard',
      theme: ThemeData(useMaterial3: true),
      home: const AuthWrapper(),
    );
  }
}
