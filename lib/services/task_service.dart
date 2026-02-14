import 'package:hive/hive.dart';
import '../models/task.dart';
import 'notification_service.dart';

class TaskService {
  final Box<Task> _box;
  final NotificationService _notificationService = NotificationService();

  TaskService._(this._box) {
    _loadFromBox();
  }

  static Future<TaskService> create() async {
    final box = Hive.box<Task>('tasks');
    return TaskService._(box);
  }

  final List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  void _loadFromBox() {
    _tasks.clear();
    _tasks.addAll(_box.values);
    _tasks.sort((a, b) => a.priority.compareTo(b.priority));
  }

  Future<void> addTask(Task task) async {
    await _box.add(task);
    _loadFromBox();
    
    // Send notification when task is added
    await _notificationService.scheduleTaskAddedNotification(task);
    
    // Schedule deadline notification for 24 hours before deadline
    await _notificationService.scheduleDeadlineNotification(task);
    
    // Schedule notification when deadline is reached
    await _notificationService.scheduleDeadlineReachedNotification(task);
  }

  Future<void> updateTask(int index, Task task) async {
    final key = _box.keyAt(index);
    await _box.put(key, task);
    _loadFromBox();
    
    // Update deadline notifications when task is updated
    await _notificationService.scheduleDeadlineNotification(task);
    await _notificationService.scheduleDeadlineReachedNotification(task);
  }

  Future<void> updateTaskEventId(Task task, String eventId) async {
    final idx = _box.values.toList().indexWhere((t) =>
        t.title == task.title && t.startDate == task.startDate && t.deadline == task.deadline && t.priority == task.priority && t.eventId == task.eventId);
    if (idx != -1) {
      final key = _box.keyAt(idx);
      final updated = Task(
        title: task.title,
        startDate: task.startDate,
        deadline: task.deadline,
        priority: task.priority,
        eventId: eventId,
      );
      await _box.put(key, updated);
    }
    _loadFromBox();
  }

  /// Re-schedule deadline and 24h notifications for all tasks (e.g. on app start).
  Future<void> rescheduleAllNotifications() async {
    for (final task in _tasks) {
      await _notificationService.scheduleDeadlineNotification(task);
      await _notificationService.scheduleDeadlineReachedNotification(task, showOverdueImmediately: false);
    }
  }

  Future<void> removeTask(Task task) async {
    // try to find matching entry in the box
    final idx = _box.values.toList().indexWhere((t) =>
        t.title == task.title && t.startDate == task.startDate && t.deadline == task.deadline && t.priority == task.priority && t.eventId == task.eventId);
    if (idx != -1) {
      final key = _box.keyAt(idx);
      await _box.delete(key);
    }
    _loadFromBox();
    
    // Cancel notifications for this task
    await _notificationService.cancelNotifications(task);
  }
}
