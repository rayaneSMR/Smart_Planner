import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/task_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settings = SettingsService();

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _rescheduleAll() async {
    final taskService = await TaskService.create();
    await taskService.rescheduleAllNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isFr = _settings.isFrench;

    String t(String fr, String en) => isFr ? fr : en;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          t('Paramètres', 'Settings'),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // ── 1. Language ───────────────────────────────────────────────────
          _SectionHeader(label: t('🌍  Langue', '🌍  Language')),
          _OptionCard(
            children: [
              _RadioTile(
                title: t('Langue du système', 'System language'),
                subtitle: t('Par défaut', 'Default'),
                value: 'system',
                groupValue: _settings.language,
                onChanged: (v) async {
                  await _settings.setLanguage(v!);
                  await _rescheduleAll();
                },
              ),
              _Divider(),
              _RadioTile(
                title: 'Français',
                value: 'fr',
                groupValue: _settings.language,
                onChanged: (v) async {
                  await _settings.setLanguage(v!);
                  await _rescheduleAll();
                },
              ),
              _Divider(),
              _RadioTile(
                title: 'English',
                value: 'en',
                groupValue: _settings.language,
                onChanged: (v) async {
                  await _settings.setLanguage(v!);
                  await _rescheduleAll();
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── 2. Theme ──────────────────────────────────────────────────────
          _SectionHeader(label: t('🎨  Thème', '🎨  Theme')),
          _OptionCard(
            children: [
              _RadioTile(
                title: t('Suivre le système', 'System default'),
                value: 'system',
                groupValue: _settings.themeMode,
                onChanged: (v) => _settings.setThemeMode(v!),
              ),
              _Divider(),
              _RadioTile(
                title: t('Clair', 'Light'),
                leading: const Icon(Icons.light_mode_outlined),
                value: 'light',
                groupValue: _settings.themeMode,
                onChanged: (v) => _settings.setThemeMode(v!),
              ),
              _Divider(),
              _RadioTile(
                title: t('Sombre', 'Dark'),
                leading: const Icon(Icons.dark_mode_outlined),
                value: 'dark',
                groupValue: _settings.themeMode,
                onChanged: (v) => _settings.setThemeMode(v!),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── 3. Deadline Reminders ─────────────────────────────────────────
          _SectionHeader(
            label: t('🔔  Rappels avant deadline', '🔔  Deadline reminders'),
          ),
          Text(
            t(
              'Sélectionnez quand recevoir des rappels avant l\'échéance d\'une tâche.',
              'Choose when to receive reminders before a task deadline.',
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),

          // Preset Delays (including 0 min Instant)
          _OptionCard(
            children: [
              for (int i = 0; i < kDefaultPresetDelays.length; i++) ...[
                if (i > 0) _Divider(),
                _CheckTile(
                  title: _settings.formatDelayLabel(kDefaultPresetDelays[i]),
                  isInstant: kDefaultPresetDelays[i] == 0,
                  value: _settings.notifDelays.contains(kDefaultPresetDelays[i]),
                  onChanged: (_) async {
                    await _settings.toggleNotifDelay(kDefaultPresetDelays[i]);
                    await _rescheduleAll();
                  },
                ),
              ],
            ],
          ),

          // Custom Delays (if any)
          if (_settings.customDelays.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                t('Personnalisés', 'Custom reminders'),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _OptionCard(
              children: [
                for (int i = 0; i < _settings.customDelays.length; i++) ...[
                  if (i > 0) _Divider(),
                  _CustomCheckTile(
                    title: _settings.formatDelayLabel(_settings.customDelays[i]),
                    value: _settings.notifDelays.contains(_settings.customDelays[i]),
                    onChanged: (_) async {
                      await _settings.toggleNotifDelay(_settings.customDelays[i]);
                      await _rescheduleAll();
                    },
                    onDelete: () async {
                      await _settings.removeCustomDelay(_settings.customDelays[i]);
                      await _rescheduleAll();
                    },
                  ),
                ],
              ],
            ),
          ],

          const SizedBox(height: 12),

          // Add Custom Reminder Button
          OutlinedButton.icon(
            onPressed: () => _showAddCustomDelayDialog(context),
            icon: const Icon(Icons.add_alarm_rounded, size: 20),
            label: Text(
              t('Ajouter un rappel personnalisé', 'Add custom reminder'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.primary,
              side: BorderSide(color: cs.primary.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              t(
                '💡 Plusieurs rappels peuvent être activés simultanément.',
                '💡 Multiple reminders can be active at the same time.',
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showAddCustomDelayDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isFr = _settings.isFrench;
    String t(String fr, String en) => isFr ? fr : en;

    final controller = TextEditingController(text: '45');
    String selectedUnit = 'minutes'; // 'minutes', 'hours', 'days'

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) {
          int computeMinutes() {
            final val = int.tryParse(controller.text.trim()) ?? 0;
            if (selectedUnit == 'days') return val * 1440;
            if (selectedUnit == 'hours') return val * 60;
            return val;
          }

          final calculatedMinutes = computeMinutes();

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.add_alarm_rounded, color: cs.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    t('Rappel personnalisé', 'Custom Reminder'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('Entrez la durée avant la deadline :', 'Enter time before deadline:'),
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'ex: 45',
                            filled: true,
                            fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          onChanged: (_) => setDlgState(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedUnit,
                              isExpanded: true,
                              icon: Icon(Icons.arrow_drop_down_rounded, color: cs.primary),
                              items: [
                                DropdownMenuItem(
                                  value: 'minutes',
                                  child: Text(t('Minutes', 'Minutes')),
                                ),
                                DropdownMenuItem(
                                  value: 'hours',
                                  child: Text(t('Heures', 'Hours')),
                                ),
                                DropdownMenuItem(
                                  value: 'days',
                                  child: Text(t('Jours', 'Days')),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setDlgState(() => selectedUnit = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (calculatedMinutes > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 16, color: cs.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              t('Aperçu : ', 'Preview: ') + _settings.formatDelayLabel(calculatedMinutes),
                              style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(t('Annuler', 'Cancel'), style: TextStyle(color: cs.onSurfaceVariant)),
              ),
              ElevatedButton(
                onPressed: calculatedMinutes <= 0
                    ? null
                    : () async {
                        Navigator.pop(ctx);
                        await _settings.addCustomDelay(calculatedMinutes);
                        await _rescheduleAll();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(t('Ajouter', 'Add')),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Reusable helper widgets ─────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
    );
  }
}

class _RadioTile extends StatelessWidget {
  const _RadioTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.subtitle,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? cs.primary : cs.onSurface,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: cs.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckTile extends StatelessWidget {
  const _CheckTile({
    required this.title,
    required this.value,
    required this.onChanged,
    this.isInstant = false,
  });

  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final bool isInstant;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            if (isInstant)
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.bolt_rounded, size: 18, color: cs.primary),
              ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: value ? FontWeight.bold : FontWeight.w500,
                  color: value ? cs.primary : cs.onSurface,
                ),
              ),
            ),
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: cs.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomCheckTile extends StatelessWidget {
  const _CustomCheckTile({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.onDelete,
  });

  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: cs.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.alarm_on_rounded, size: 18, color: cs.secondary),
          ),
          Expanded(
            child: InkWell(
              onTap: () => onChanged(!value),
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: value ? FontWeight.bold : FontWeight.w500,
                  color: value ? cs.primary : cs.onSurface,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red[600]),
            onPressed: onDelete,
            tooltip: SettingsService().isFrench ? 'Supprimer' : 'Delete',
          ),
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: cs.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ],
      ),
    );
  }
}
