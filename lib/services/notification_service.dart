import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone_latest/flutter_native_timezone_latest.dart';
import '../models/task.dart';
import 'settings_service.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final SettingsService _settings = SettingsService();

  int _taskNotificationId(Task task) {
    var hash = 2166136261;
    final value =
        '${task.title}|${task.startDate.microsecondsSinceEpoch}|${task.deadline.microsecondsSinceEpoch}|${task.priority}';
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 16777619) & 0x7fffffff;
    }
    return hash;
  }

  Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();
    final String timeZoneName =
        await FlutterNativeTimezoneLatest.getLocalTimezone();
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(settings: settings);

    // Request notification permission for Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // Request exact alarm permission (Android 12+)
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();
  }

  /// Immediate notification shown when a new task is created.
  Future<void> showNewTaskNotification(Task task) async {
    const androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Tasks',
      channelDescription: 'Notifications for task events',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: _taskNotificationId(task),
      title: _settings.t('Nouvelle tâche ajoutée', 'New task added'),
      body: task.title,
      notificationDetails: details,
    );
  }

  Future<void> scheduleTaskAddedNotification(Task task) async {
    await showNewTaskNotification(task);
  }

  /// Schedule a single reminder [minutesBefore] minutes before deadline.
  /// If [minutesBefore] is 0, this fires exactly at the deadline (instant).
  Future<void> _scheduleReminderAtOffset(
    Task task,
    int minutesBefore,
    int idSalt,
  ) async {
    final scheduled = task.deadline.subtract(Duration(minutes: minutesBefore));
    final now = DateTime.now();
    if (scheduled.isBefore(now)) return;

    final tzDate = tz.TZDateTime.from(scheduled, tz.local);

    final String title;
    final String body;

    if (minutesBefore == 0) {
      title = _settings.t(
        'Deadline atteinte : ${task.title}',
        'Deadline reached: ${task.title}',
      );
      body = _settings.t(
        'Votre tâche a atteint sa deadline',
        'Your task has reached its deadline',
      );
    } else {
      title = _settings.t(
        'Rappel : ${task.title}',
        'Reminder: ${task.title}',
      );
      body = _settings.formatDelayNotificationBody(minutesBefore);
    }

    const androidDetails = AndroidNotificationDetails(
      'deadline_channel',
      'Deadlines',
      channelDescription: 'Reminders for task deadlines',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id: _taskNotificationId(task) ^ idSalt,
      title: title,
      body: body,
      scheduledDate: tzDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
    );
  }

  /// Schedules all user-configured reminder offsets (including instant 0-min if enabled).
  Future<void> scheduleDeadlineNotification(Task task) async {
    final delays = _settings.notifDelays.toList()..sort();
    int saltIndex = 0;
    for (final minutes in delays) {
      await _scheduleReminderAtOffset(
        task,
        minutes,
        0x100000 + saltIndex * 0x10000,
      );
      saltIndex++;
    }
  }

  /// Overdue check or fallback if task deadline is already past.
  Future<void> scheduleDeadlineReachedNotification(
    Task task, {
    bool showOverdueImmediately = true,
  }) async {
    final now = DateTime.now();
    if (task.deadline.isBefore(now)) {
      if (showOverdueImmediately) {
        await _showDeadlineOverdueNotification(task);
      }
      return;
    }

    // If 0-minute instant reminder is not in notifDelays, schedule the deadline reached alarm here
    if (!_settings.notifDelays.contains(0)) {
      final tzDate = tz.TZDateTime.from(task.deadline, tz.local);

      const androidDetails = AndroidNotificationDetails(
        'deadline_reached_channel',
        'Deadline Reached',
        channelDescription: 'Notifications when task deadlines are reached',
        importance: Importance.max,
        priority: Priority.max,
      );
      const iosDetails = DarwinNotificationDetails();
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.zonedSchedule(
        id: _taskNotificationId(task) ^ 0x200000,
        title: _settings.t(
          'Deadline atteinte : ${task.title}',
          'Deadline reached: ${task.title}',
        ),
        body: _settings.t(
          'Votre tâche a atteint sa deadline',
          'Your task has reached its deadline',
        ),
        scheduledDate: tzDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
      );
    }
  }

  Future<void> _showDeadlineOverdueNotification(Task task) async {
    const androidDetails = AndroidNotificationDetails(
      'deadline_reached_channel',
      'Deadline Reached',
      channelDescription: 'Notifications when task deadlines are reached',
      importance: Importance.max,
      priority: Priority.max,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(
      id: _taskNotificationId(task) ^ 0x200000,
      title: _settings.t(
        'Tâche en retard : ${task.title}',
        'Task overdue: ${task.title}',
      ),
      body: _settings.t(
        'La deadline de cette tâche est dépassée',
        'The deadline for this task has passed',
      ),
      notificationDetails: details,
    );
  }

  Future<void> scheduleDeadlineReminder(Task task) async {
    await scheduleDeadlineNotification(task);
  }

  Future<void> cancelNotifications(Task task) async {
    final notificationId = _taskNotificationId(task);
    await _plugin.cancel(id: notificationId);
    // Cancel up to 30 possible reminder slots
    for (int i = 0; i < 30; i++) {
      await _plugin.cancel(id: notificationId ^ (0x100000 + i * 0x10000));
    }
    await _plugin.cancel(id: notificationId ^ 0x200000);
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  Future<void> cancelNotificationForTask(Task task) async {
    await cancelNotifications(task);
  }
}
