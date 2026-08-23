import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../widgets/task_card.dart';
import '../widgets/calendar_widget.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TaskService? taskService;
  int _currentIndex = 0;
  final _settings = SettingsService();

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettingsChanged);
    TaskService.create().then((s) async {
      await s.rescheduleAllNotifications();
      if (mounted) {
        setState(() {
          taskService = s;
        });
      }
    });
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isFr = _settings.isFrench;
    String t(String fr, String en) => isFr ? fr : en;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withValues(alpha: 0.08),
              colorScheme.secondary.withValues(alpha: 0.08),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.task_alt,
                            color: colorScheme.onPrimary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Smart Planner',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                t('Organisez votre journée en toute simplicité', 'Organize your day with ease'),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Settings button
                        Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.settings_outlined,
                              color: colorScheme.onSurfaceVariant,
                              size: 22,
                            ),
                            tooltip: t('Paramètres', 'Settings'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SettingsScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Navigation Tabs (Full Width)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _currentIndex = 0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: _currentIndex == 0
                                      ? colorScheme.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.list,
                                      size: 20,
                                      color: _currentIndex == 0
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      t('Tâches', 'Tasks'),
                                      style: TextStyle(
                                        color: _currentIndex == 0
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSurfaceVariant,
                                        fontWeight: _currentIndex == 0
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _currentIndex = 1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: _currentIndex == 1
                                      ? colorScheme.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 18,
                                      color: _currentIndex == 1
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      t('Calendrier', 'Calendar'),
                                      style: TextStyle(
                                        color: _currentIndex == 1
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSurfaceVariant,
                                        fontWeight: _currentIndex == 1
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Body Content
              Expanded(
                child: taskService == null
                    ? Center(
                        child: CircularProgressIndicator(
                          color: colorScheme.primary,
                        ),
                      )
                    : _currentIndex == 0
                    ? _buildTasksList(theme, colorScheme, isFr)
                    : CalendarWidget(
                        tasks: taskService!.tasks,
                        onDelete: _confirmDelete,
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskBottomSheet,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: Text(
          t('Nouvelle tâche', 'New task'),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildTasksList(ThemeData theme, ColorScheme colorScheme, bool isFr) {
    final tasks = taskService!.tasks;
    String t(String fr, String en) => isFr ? fr : en;

    if (tasks.isEmpty) {
      return Center(
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
                Icons.task_outlined,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t('Aucune tâche pour le moment', 'No tasks yet'),
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t(
                'Appuyez sur le bouton + pour en créer une',
                'Tap the + button to create one',
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return TaskCard(
          task: tasks[index],
          onDelete: () => _confirmDelete(tasks[index]),
        );
      },
    );
  }

  void _confirmDelete(Task task) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isFr = _settings.isFrench;
    String t(String fr, String en) => isFr ? fr : en;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.delete_outline, color: Colors.red[700]),
            ),
            const SizedBox(width: 12),
            Text(t('Supprimer la tâche', 'Delete task')),
          ],
        ),
        content: Text(
          isFr
              ? 'Êtes-vous sûr de vouloir supprimer "${task.title}" ?'
              : 'Are you sure you want to delete "${task.title}"?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              t('Annuler', 'Cancel'),
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(t('Supprimer', 'Delete')),
          ),
        ],
      ),
    );

    if (confirmed == true && taskService != null) {
      await NotificationService().cancelNotificationForTask(task);
      await taskService!.removeTask(task);
      setState(() {});
    }
  }

  void _showAddTaskBottomSheet() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isFr = _settings.isFrench;
    String t(String fr, String en) => isFr ? fr : en;

    String title = '';
    DateTime startDate = DateTime.now();
    DateTime deadline = DateTime.now().add(const Duration(hours: 2));
    int priority = 2;

    if (!mounted) return;

    final newTask = await showModalBottomSheet<Task>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.add_task, color: colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      t('Nouvelle tâche', 'New task'),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Form
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title input
                      Text(
                        t('Titre de la tâche', 'Task title'),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: t(
                            'Entrez le titre de votre tâche',
                            'Enter your task title',
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.3,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.edit_outlined),
                        ),
                        onChanged: (value) => setState(() => title = value),
                      ),
                      const SizedBox(height: 20),
                      // Dates row
                      Row(
                        children: [
                          // Start Date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t('Date de début', 'Start date'),
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: startDate,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        startDate = DateTime(
                                          picked.year,
                                          picked.month,
                                          picked.day,
                                          startDate.hour,
                                          startDate.minute,
                                        );
                                        if (deadline.isBefore(startDate)) {
                                          deadline = startDate.add(
                                            const Duration(hours: 1),
                                          );
                                        }
                                      });
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest.withValues(
                                        alpha: 0.3,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 18,
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            startDate.toLocal().toString().split(' ')[0],
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Deadline
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t('Date limite', 'Deadline'),
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: deadline,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null) {
                                      if (!context.mounted) return;
                                      final pickedTime = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.fromDateTime(deadline),
                                      );
                                      setState(() {
                                        deadline = DateTime(
                                          picked.year,
                                          picked.month,
                                          picked.day,
                                          pickedTime?.hour ?? deadline.hour,
                                          pickedTime?.minute ?? deadline.minute,
                                        );
                                      });
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest.withValues(
                                        alpha: 0.3,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 18,
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${deadline.toLocal().toString().split(' ')[0]} ${TimeOfDay.fromDateTime(deadline.toLocal()).format(context)}',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Priority selector
                      Text(
                        t('Niveau de priorité', 'Priority level'),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => priority = 1),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: priority == 1
                                      ? Colors.red.withValues(alpha: 0.1)
                                      : colorScheme.surfaceContainerHighest.withValues(
                                          alpha: 0.3,
                                        ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: priority == 1
                                      ? Border.all(color: Colors.red, width: 2)
                                      : null,
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.priority_high,
                                      color: priority == 1
                                          ? Colors.red
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      t('Urgent', 'Urgent'),
                                      style: TextStyle(
                                        color: priority == 1
                                            ? Colors.red
                                            : colorScheme.onSurfaceVariant,
                                        fontWeight: priority == 1
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => priority = 2),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: priority == 2
                                      ? Colors.orange.withValues(alpha: 0.1)
                                      : colorScheme.surfaceContainerHighest.withValues(
                                          alpha: 0.3,
                                        ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: priority == 2
                                      ? Border.all(color: Colors.orange, width: 2)
                                      : null,
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      color: priority == 2
                                          ? Colors.orange
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      t('Modéré', 'Moderate'),
                                      style: TextStyle(
                                        color: priority == 2
                                            ? Colors.orange
                                            : colorScheme.onSurfaceVariant,
                                        fontWeight: priority == 2
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => priority = 3),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: priority == 3
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : colorScheme.surfaceContainerHighest.withValues(
                                          alpha: 0.3,
                                        ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: priority == 3
                                      ? Border.all(color: Colors.green, width: 2)
                                      : null,
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.low_priority,
                                      color: priority == 3
                                          ? Colors.green
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      t('Faible', 'Low'),
                                      style: TextStyle(
                                        color: priority == 3
                                            ? Colors.green
                                            : colorScheme.onSurfaceVariant,
                                        fontWeight: priority == 3
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // Bottom actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          t('Annuler', 'Cancel'),
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: title.trim().isEmpty
                            ? null
                            : () {
                                Navigator.pop(
                                  context,
                                  Task(
                                    title: title.trim(),
                                    startDate: startDate,
                                    deadline: deadline,
                                    priority: priority,
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          t('Créer la tâche', 'Create task'),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (newTask != null && taskService != null) {
      await taskService!.addTask(newTask);
      setState(() {});
    }
  }
}
