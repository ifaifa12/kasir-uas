import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) return;
    
    tz.initializeTimeZones();
    // Default to Jakarta if dynamic timezone causes issues
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {},
    );
  }

  Future<bool> requestPermission() async {
    if (kIsWeb) return true;
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      status = await Permission.notification.request();
    }
    return status.isGranted;
  }

  Future<void> showImmediateNotification() async {
    if (kIsWeb) return;
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'immediate_reminder',
      'Immediate Reminder',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
      id: 1,
      title: 'Waktunya Menabung! ⏰',
      body: 'Jangan lupa sisihkan uang untuk target tabunganmu hari ini.',
      notificationDetails: notificationDetails,
    );
  }

  Future<void> scheduleWeeklyReminders(int hour, int minute, List<int> days) async {
    // Hidden feature
  }

  Future<void> scheduleWeeklyRemindersForTarget(String targetId, String targetNama, int hour, int minute, List<int> days) async {
    // Hidden feature
  }

  Future<void> cancelRemindersForTarget(String targetId) async {
    if (kIsWeb) return;
    for (int day = 1; day <= 7; day++) {
      int notificationId = (targetId.hashCode & 0x0FFFFFFF) + (day * 10000000);
      await flutterLocalNotificationsPlugin.cancel(id: notificationId);
    }
  }

  Future<void> cancelAllReminders() async {
    if (kIsWeb) return;
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}