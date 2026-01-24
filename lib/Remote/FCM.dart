import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gms_flutter/Shared/LocalNotification.dart';

class FirebaseMessagingService {
  FirebaseMessagingService() {
    _setup();
  }

  void _setup() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? '';
      final body = message.notification?.body ?? '';
      LocalNotificationService.showNotification(title: title, body: body);
    });

    // When user taps a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Opened from notification");
    });
  }
}
