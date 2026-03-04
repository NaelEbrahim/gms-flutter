import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gms_flutter/BLoC/Manager.dart';
import 'package:gms_flutter/Shared/LocalNotification.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  FirebaseMessagingService() {
    _setup();
  }

  static void registerUserToken() {
    // send initial token
    _sendTokenToServer();
    // Listen for token changed
    _messaging.onTokenRefresh.listen((newToken) {
      _sendTokenToServer(token: newToken);
    });
  }

  void _setup() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? '';
      final body = message.notification?.body ?? '';
      LocalNotificationService.showNotification(title: title, body: body);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
  }

  static Future<void> _sendTokenToServer({String? token}) async {
    final fcmToken = token ?? await _messaging.getToken();
    if (fcmToken == null) return;
    Manager manager = Manager();
    manager.saveFCM({'fcmToken': fcmToken});
  }
}
