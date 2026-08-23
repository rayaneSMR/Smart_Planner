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
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          t('Paramètres', 'Settings'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: cs.onSurface,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            children: [
              // ── 1. Language ──
              _SectionHeader(label: t('Langue', 'Language')),
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

              const SizedBox(height: 18),

              // ── 2. Theme ──
              _SectionHeader(label: t('Thème', 'Theme')),
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
                    value: 'light',
                    groupValue: _settings.themeMode,
                    onChanged: (v) => _settings.setThemeMode(v!),
                  ),
                  _Divider(),
                  _RadioTile(
                    title: t('Sombre', 'Dark'),
                    value: 'dark',
                    groupValue: _settings.themeMode,
                    onChanged: (v) => _settings.setThemeMode(v!),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ── 3. Deadline Reminders ──
              _SectionHeader(label: t('Rappels avant deadline', 'Deadline reminders')),
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 6),
                child: Text(
                  t(
                    "Sélectionnez quand recevoir des rappels avant l'échéance d'une tâche.",
                    "Choose when to receive reminders before a task deadline.",
                  ),
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
                ),
              ),

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
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(
                    t('Personnalisés', 'Custom reminders'),
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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

              const SizedBox(height: 10),

              // Add Custom Reminder Button
              OutlinedButton(
                onPressed: () => _showAddCustomDelayDialog(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.primary,
                  side: BorderSide(color: cs.primary.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  t('+ Ajouter un rappel personnalisé', '+ Add custom reminder'),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),

              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  t(
                    'Plusieurs rappels peuvent être activés simultanément.',
                    'Multiple reminders can be active at the same time.',
                  ),
                  style: TextStyle(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                    fontSize: 11,
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCustomDelayDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isFr = _settings.isFrench;
    String t(String fr, String en) => isFr ? fr : en;

    final controller = TextEditingController(text: '45');
    String selectedUnit = 'minutes';

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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Text(
              t('Rappel personnalisé', 'Custom Reminder'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('Durée avant la deadline :', 'Time before deadline:'),
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: '45',
                            filled: true,
                            fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.25),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          onChanged: (_) => setDlgState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedUnit,
                              isExpanded: true,
                              icon: Icon(Icons.arrow_drop_down_rounded, color: cs.primary),
                              items: [
                                DropdownMenuItem(
                                  value: 'minutes',
                                  child: Text(t('Minutes', 'Minutes'), style: const TextStyle(fontSize: 13)),
                                ),
                                DropdownMenuItem(
                                  value: 'hours',
                                  child: Text(t('Heures', 'Hours'), style: const TextStyle(fontSize: 13)),
                                ),
                                DropdownMenuItem(
                                  value: 'days',
                                  child: Text(t('Jours', 'Days'), style: const TextStyle(fontSize: 13)),
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
                  const SizedBox(height: 10),
                  if (calculatedMinutes > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        t('Aperçu : ', 'Preview: ') + _settings.formatDelayLabel(calculatedMinutes),
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(t('Annuler', 'Cancel'), style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
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
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(t('Ajouter', 'Add'), style: const TextStyle(fontSize: 13)),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Reusable helper widgets ──

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
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
        color: cs.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
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
      indent: 12,
      endIndent: 12,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
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
  });

  final String title;
  final String? subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? cs.primary : cs.onSurface,
                      fontSize: 13,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11,
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
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: value ? FontWeight.bold : FontWeight.w500,
                  color: value ? cs.primary : cs.onSurface,
                  fontSize: 13,
                ),
              ),
            ),
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: cs.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => onChanged(!value),
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: value ? FontWeight.bold : FontWeight.w500,
                  color: value ? cs.primary : cs.onSurface,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          IconButton(
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            padding: EdgeInsets.zero,
            icon: Icon(Icons.close_rounded, size: 16, color: Colors.red[600]),
            onPressed: onDelete,
            tooltip: SettingsService().isFrench ? 'Supprimer' : 'Delete',
          ),
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: cs.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ],
      ),
    );
  }
}
