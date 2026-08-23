import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/settings_service.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onDelete,
  });

  Color _priorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _priorityText(int priority, bool isFr) {
    switch (priority) {
      case 1:
        return isFr ? 'Urgent' : 'Urgent';
      case 2:
        return isFr ? 'Modéré' : 'Moderate';
      case 3:
        return isFr ? 'Faible' : 'Low';
      default:
        return isFr ? 'Normal' : 'Normal';
    }
  }

  IconData _priorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icons.priority_high;
      case 2:
        return Icons.schedule;
      case 3:
        return Icons.low_priority;
      default:
        return Icons.help_outline;
    }
  }

  bool _isOverdue() {
    return DateTime.now().isAfter(task.deadline);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final priorityColor = _priorityColor(task.priority);
    final isOverdue = _isOverdue();
    final isFr = SettingsService().isFrench;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and delete button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Priority indicator icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _priorityIcon(task.priority),
                        color: priorityColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title and priority badge
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Priority badge & Overdue badge
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: priorityColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _priorityText(task.priority, isFr),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: priorityColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (isOverdue)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isFr ? 'En retard' : 'Overdue',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: Colors.red[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Delete button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        padding: const EdgeInsets.all(6),
                        onPressed: onDelete,
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red[700],
                          size: 20,
                        ),
                        tooltip: isFr ? 'Supprimer' : 'Delete',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Date information
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: isOverdue
                            ? Colors.red[700]
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isFr ? 'Date limite' : 'Deadline',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '${task.deadline.toLocal().toString().split(' ')[0]} ${TimeOfDay.fromDateTime(task.deadline.toLocal()).format(context)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isOverdue
                                    ? Colors.red[700]
                                    : colorScheme.onSurface,
                                fontWeight: isOverdue
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Start date (shown if different day from deadline)
                if (task.startDate.toLocal().toString().split(' ')[0] !=
                    task.deadline.toLocal().toString().split(' ')[0]) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isFr ? 'Date de début' : 'Start date',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              task.startDate.toLocal().toString().split(' ')[0],
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
