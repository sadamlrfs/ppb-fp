import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final _fcm = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();

  static const _channelId = 'mindease_channel';
  static const _channelName = 'MindEase Notifications';

  Future<void> init() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            importance: Importance.high,
          ),
        );

    FirebaseMessaging.onMessage.listen(_handleForeground);
  }

  Future<String?> getToken() => _fcm.getToken();

  Future<void> _handleForeground(RemoteMessage message) async {
    final n = message.notification;
    if (n == null) return;
    await showLocal(title: n.title ?? 'MindEase', body: n.body ?? '');
  }

  Future<void> showLocal({
    required String title,
    required String body,
    int id = 0,
  }) =>
      _local.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
}
