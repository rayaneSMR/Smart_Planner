import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';
import '../services/settings_service.dart';
import 'task_card.dart';

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class CalendarWidget extends StatefulWidget {
  final List<Task> tasks;
  final Function(Task) onDelete;

  const CalendarWidget({
    super.key,
    required this.tasks,
    required this.onDelete,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Task> _getTasksForDay(DateTime day) {
    return widget.tasks.where((task) {
      return task.deadline.year == day.year &&
          task.deadline.month == day.month &&
          task.deadline.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isFr = SettingsService().isFrench;
    final tasks = _selectedDay == null ? [] : _getTasksForDay(_selectedDay!);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TableCalendar(
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2100),
            focusedDay: _focusedDay,
            locale: isFr ? 'fr_FR' : 'en_US',
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              outsideDaysVisible: true,
              weekendTextStyle: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ) ?? const TextStyle(),
              defaultTextStyle: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ) ?? const TextStyle(),
              selectedTextStyle: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ) ?? const TextStyle(),
              todayTextStyle: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ) ?? const TextStyle(),
              defaultDecoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.primary, width: 1),
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ) ?? const TextStyle(),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: colorScheme.onSurface,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ) ?? const TextStyle(),
              weekendStyle: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ) ?? const TextStyle(),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${day.day}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ) ?? const TextStyle(),
                  ),
                );
              },
              selectedBuilder: (context, day, focusedDay) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${day.day}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ) ?? const TextStyle(),
                  ),
                );
              },
              todayBuilder: (context, day, focusedDay) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.primary, width: 1),
                  ),
                  child: Text(
                    '${day.day}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ) ?? const TextStyle(),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.event_busy_outlined,
                          size: 48,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isFr ? "Aucune tâche pour ce jour" : "No tasks for this day",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ) ?? const TextStyle(),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TaskCard(
                          task: tasks[index],
                          onDelete: () => widget.onDelete(tasks[index]),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
