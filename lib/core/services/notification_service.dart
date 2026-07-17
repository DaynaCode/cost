import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel(
      'budget_alerts',
      'هشدار بودجه',
      description: 'اطلاع رسانی رسیدن به آستانه بودجه',
      importance: Importance.high,
    ));
    await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel(
      'reminders',
      'یادآوری ها',
      description: 'یادآوری ثبت تراکنش و تراکنش های تکرارشونده',
      importance: Importance.defaultImportance,
    ));

    _initialized = true;
  }

  Future<void> showBudgetAlert({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alerts',
          'هشدار بودجه',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await _plugin.cancel(9001);
    await _plugin.zonedSchedule(
      9001,
      'ثبت هزینه های امروز',
      'فراموش نکنید تراکنش های امروز را ثبت کنید',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders',
          'یادآوری ها',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(9001);
  }

  Future<void> scheduleRecurringReminder({
    required int id,
    required String title,
    required DateTime dateTime,
  }) async {
    await _plugin.zonedSchedule(
      id,
      'تراکنش تکرارشونده',
      title,
      tz.TZDateTime.from(dateTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders',
          'یادآوری ها',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) => _plugin.cancel(id);

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
