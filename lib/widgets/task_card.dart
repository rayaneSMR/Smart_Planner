import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/settings_service.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;

  const TaskCard({super.key, required this.task, required this.onDelete});

  Color _priorityColor(int p) {
    if (p == 1) return Colors.red;
    if (p == 2) return Colors.orange;
    return Colors.green;
  }

  String _priorityText(int p, bool isFr) {
    if (p == 1) return isFr ? "Urgent" : "Urgent";
    if (p == 2) return isFr ? "Modéré" : "Moderate";
    return isFr ? "Faible" : "Low";
  }

  IconData _priorityIcon(int p) {
    if (p == 1) return Icons.priority_high;
    if (p == 2) return Icons.schedule;
    return Icons.low_priority;
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
      margin: const EdgeInsets.only(bottom: 8),
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
        border: Border.all(
          color: isOverdue
              ? Colors.red.withValues(alpha: 0.3)
              : colorScheme.outline.withValues(alpha: 0.1),
          width: isOverdue ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and delete button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Priority indicator
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _priorityIcon(task.priority),
                        color: priorityColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title
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
                          // Priority badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: priorityColor.withValues(alpha: 0.1),
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
                const SizedBox(height: 16),
                // Date information
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
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
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isOverdue) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
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
                    ],
                  ),
                ),
                // Start date (shown if different day from deadline)
                if (task.startDate.toLocal().toString().split(' ')[0] !=
                    task.deadline.toLocal().toString().split(' ')[0]) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          size: 18,
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
                              ),
                            ),
                            Text(
                              task.startDate.toLocal().toString().split(' ')[0],
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
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
