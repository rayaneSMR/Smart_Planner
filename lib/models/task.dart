import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime startDate;

  @HiveField(2)
  DateTime deadline;

  @HiveField(3)
  int priority;

  /// Optional Google Calendar event id if synced to calendar
  @HiveField(4)
  String? eventId;

  Task({
    required this.title,
    required this.startDate,
    required this.deadline,
    required this.priority,
    this.eventId,
  });
}
