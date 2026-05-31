import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) return;
    
    // Inisialisasi timezone dan set ke Asia/Jakarta secara eksplisit
    tz.initializeTimeZones();
    final jakarta = tz.getLocation('Asia/Jakarta');
    tz.setLocalLocation(jakarta);

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
    await requestPermission();
  }

  /// Dipanggil setelah HP restart untuk menjadwal ulang semua notifikasi aktif
  Future<void> rescheduleAllOnBoot() async {
    if (kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();

    // Reschedule global reminder
    final bool globalActive = prefs.getBool('isReminderActive') ?? false;
    final int? globalHour = prefs.getInt('reminderHour');
    final int? globalMinute = prefs.getInt('reminderMinute');
    final List<String>? globalDays = prefs.getStringList('reminderDays');
    if (globalActive && globalHour != null && globalMinute != null && globalDays != null && globalDays.isNotEmpty) {
      final days = globalDays.map(int.parse).toList();
      await scheduleWeeklyReminders(globalHour, globalMinute, days);
    }

    // Reschedule per-target reminders
    final String? dataString = prefs.getString('tabungan_data');
    if (dataString != null) {
      try {
        // ignore: depend_on_referenced_packages
        final List<dynamic> jsonList = await _decodeJson(dataString);
        for (final item in jsonList) {
          final bool active = item['isReminderActive'] ?? false;
          final int? hour = item['reminderHour'];
          final int? minute = item['reminderMinute'];
          final List<int> days = item['reminderDays'] != null
              ? List<int>.from(item['reminderDays'])
              : [1, 2, 3, 4, 5, 6, 7];
          if (active && hour != null && minute != null && days.isNotEmpty) {
            await scheduleWeeklyRemindersForTarget(
              item['id'], item['nama'], hour, minute, days);
          }
        }
      } catch (_) {}
    }
  }

  List<dynamic> _decodeJson(String data) {
    return jsonDecode(data);
  }

  Future<bool> requestPermission() async {
    if (kIsWeb) return true;
    
    var status = await Permission.notification.status;
    if (status.isGranted) {
      return true;
    }
    
    status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<void> showImmediateNotification() async {
    if (kIsWeb) return;
    
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'immediate_reminder',
      'Immediate Reminder',
      channelDescription: 'Pengingat langsung untuk menabung',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
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
    if (kIsWeb) return;
    
    await cancelAllReminders();
    
    for (int day in days) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: day,
        title: 'Waktunya Menabung!',
        body: 'Jangan lupa sisihkan uang untuk target tabunganmu hari ini.',
        scheduledDate: _nextInstanceOfDayAndTime(day, hour, minute),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'weekly_reminder',
            'Weekly Reminder',
            channelDescription: 'Pengingat harian untuk menabung',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> scheduleWeeklyRemindersForTarget(String targetId, String targetNama, int hour, int minute, List<int> days) async {
    if (kIsWeb) return;
    
    await cancelRemindersForTarget(targetId);
    
    for (int day in days) {
      int notificationId = (targetId.hashCode & 0x0FFFFFFF) + (day * 10000000);
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: notificationId,
        title: 'Tabungan ${targetNama} ⏰',
        body: 'Ayo isi tabungan "${targetNama}" kamu hari ini agar target cepat tercapai!',
        scheduledDate: _nextInstanceOfDayAndTime(day, hour, minute),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'target_reminder',
            'Target Reminder',
            channelDescription: 'Pengingat untuk masing-masing target tabungan',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
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

  tz.TZDateTime _nextInstanceOfDayAndTime(int day, int hour, int minute) {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);
    while (scheduledDate.weekday != day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}