import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone_latest/flutter_native_timezone_latest.dart';
import '../models/task.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezoneLatest.getLocalTimezone();
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
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showNewTaskNotification(Task task) async {
    const androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Tasks',
      channelDescription: 'Notifications for task events',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      id: task.hashCode,
      title: 'Nouvelle tâche ajoutée',
      body: task.title,
      notificationDetails: details,
    );
  }

  Future<void> scheduleTaskAddedNotification(Task task) async {
    await showNewTaskNotification(task);
  }

  Future<void> scheduleDeadlineNotification(Task task) async {
    final scheduled = task.deadline.subtract(const Duration(hours: 24));
    final now = DateTime.now();
    if (scheduled.isBefore(now)) {
      return;
    }

    final tzDate = tz.TZDateTime.from(scheduled, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'deadline_channel',
      'Deadlines',
      channelDescription: 'Reminders for task deadlines',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      id: task.hashCode ^ 0x100000,
      title: 'Rappel: ${task.title}',
      body: 'Votre tâche a une deadline dans 24h',
      scheduledDate: tzDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> scheduleDeadlineReachedNotification(Task task) async {
    if (task.deadline.isBefore(DateTime.now())) {
      return;
    }

    final tzDate = tz.TZDateTime.from(task.deadline, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'deadline_reached_channel',
      'Deadline Reached',
      channelDescription: 'Notifications when task deadlines are reached',
      importance: Importance.max,
      priority: Priority.max,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      id: task.hashCode ^ 0x200000,
      title: 'Deadline atteinte: ${task.title}',
      body: 'Votre tâche a atteint sa deadline',
      scheduledDate: tzDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> scheduleDeadlineReminder(Task task) async {
    await scheduleDeadlineNotification(task);
  }

  Future<void> cancelNotifications(Task task) async {
    await _plugin.cancel(id: task.hashCode);
    await _plugin.cancel(id: task.hashCode ^ 0x100000);
    await _plugin.cancel(id: task.hashCode ^ 0x200000);
  }

  Future<void> cancelNotificationForTask(Task task) async {
    await cancelNotifications(task);
  }
}
