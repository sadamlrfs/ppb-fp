import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _fcm = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();

  static const _channelId = 'mindease_channel';
  static const _channelName = 'MindEase Notifications';
  static const morningId = 1;
  static const eveningId = 2;

  // Diisi saat init() selesai
  bool _canExact = false;

  static const morningMessages = [
    'Selamat pagi! 🌞 Bagaimana perasaanmu hari ini?',
    'Pagi yang cerah! ☀️ Yuk ceritakan mood kamu sekarang.',
    'Hei, selamat pagi! 😊 Sudah siap menjalani hari ini?',
    'Pagi! 🌅 Luangkan sedikit waktu untuk cek perasaanmu.',
  ];

  static const eveningMessages = [
    'Selamat malam! 🌙 Bagaimana harimu hari ini?',
    'Malam! ✨ Yuk catat perasaanmu sebelum istirahat.',
    'Hei, sudah malam. 🌟 Bagaimana perasaanmu sekarang?',
    'Malam yang tenang! 🌛 Ceritakan bagaimana harimu berjalan.',
  ];

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    final androidPlugin = _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Android 13+ runtime permission
    await androidPlugin?.requestNotificationsPermission();

    // Android 12+ exact alarm permission — buka halaman Settings jika belum granted
    await androidPlugin?.requestExactAlarmsPermission();

    // Simpan status exact alarm untuk dipakai saat scheduling
    _canExact =
        await androidPlugin?.canScheduleExactNotifications() ?? false;

    debugPrint('[Notification] canScheduleExact=$_canExact');

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
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

  /// Kirim notifikasi percobaan yang dijadwal 10 detik ke depan
  /// menggunakan pesan asli sesuai waktu sekarang (pagi/malam).
  Future<void> scheduleTestReminder() async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduled = now.add(const Duration(seconds: 10));

    final messages =
        now.hour < 15 ? morningMessages : eveningMessages;
    final body = messages[Random().nextInt(messages.length)];

    await _local.zonedSchedule(
      98,
      'MindEase',
      body,
      scheduled,
      _notifDetails(),
      androidScheduleMode: _canExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    debugPrint('[Notification] Test scheduled at $scheduled');
  }

  /// Schedule notifikasi harian berulang setiap hari pukul [hour]:[minute].
  Future<void> scheduleReminder({
    required int id,
    required int hour,
    required int minute,
    required List<String> messages,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final body = messages[Random().nextInt(messages.length)];

    await _local.zonedSchedule(
      id,
      'MindEase',
      body,
      scheduled,
      _notifDetails(),
      androidScheduleMode: _canExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    debugPrint('[Notification] Scheduled id=$id at ${_pad(hour)}:${_pad(minute)} '
        '(next: $scheduled, exact=$_canExact)');
  }

  Future<void> cancelReminder(int id) async {
    await _local.cancel(id);
    debugPrint('[Notification] Cancelled id=$id');
  }

  NotificationDetails _notifDetails() => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

  String _pad(int v) => v.toString().padLeft(2, '0');
}
