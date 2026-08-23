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
              colorScheme.primary.withValues(alpha: 0.1),
              colorScheme.secondary.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
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
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Smart Planner',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                t('Organisez votre journée', 'Organize your day'),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
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
                    const SizedBox(height: 24),
                    // Navigation Tabs
                    Container(
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
                                  vertical: 16,
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
                                  vertical: 16,
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
              // Content
              Expanded(
                child: taskService == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              t('Chargement...', 'Loading...'),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showAddTaskBottomSheet,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          icon: const Icon(Icons.add),
          label: Text(t('Nouvelle tâche', 'New task')),
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
                color: colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 64,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t('Aucune tâche', 'No tasks'),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t(
                'Appuyez sur + pour ajouter votre première tâche',
                'Tap + to add your first task',
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TaskCard(
              task: tasks[index],
              onDelete: () => _confirmDelete(tasks[index]),
            ),
          );
        },
      ),
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
                borderRadius: BorderRadius.circular(12),
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
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
    int priority = 2; // 1=Urgent, 2=Moderate, 3=Low

    if (!mounted) return;

    final newTask = await showModalBottomSheet<Task>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
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
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.add_task,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        t('Nouvelle tâche', 'New task'),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title field
                      Text(
                        t('Titre', 'Title'),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: t('Entrez le titre de la tâche', 'Enter task title'),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.3,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        onChanged: (value) => title = value,
                      ),
                      const SizedBox(height: 24),

                      // Dates section
                      Text(
                        t('Dates', 'Dates'),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest.withValues(
                                  alpha: 0.3,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t('Début', 'Start'),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TextButton(
                                    onPressed: () async {
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
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                    ),
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest.withValues(
                                  alpha: 0.3,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t('Deadline', 'Deadline'),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TextButton(
                                    onPressed: () async {
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
                                          initialTime: TimeOfDay.fromDateTime(
                                            deadline,
                                          ),
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
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                    ),
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
                      const SizedBox(height: 24),

                      // Priority section
                      Text(
                        t('Priorité', 'Priority'),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => priority = 1),
                              child: Container(
                                padding: const EdgeInsets.all(16),
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => priority = 2),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: priority == 2
                                      ? Colors.orange.withValues(alpha: 0.1)
                                      : colorScheme.surfaceContainerHighest.withValues(
                                          alpha: 0.3,
                                        ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: priority == 2
                                      ? Border.all(
                                          color: Colors.orange,
                                          width: 2,
                                        )
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => priority = 3),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: priority == 3
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : colorScheme.surfaceContainerHighest.withValues(
                                          alpha: 0.3,
                                        ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: priority == 3
                                      ? Border.all(
                                          color: Colors.green,
                                          width: 2,
                                        )
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
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              // Bottom actions
              Container(
                padding: const EdgeInsets.all(24),
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
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
