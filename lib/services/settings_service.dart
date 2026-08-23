import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Built-in preset delays in minutes before the deadline.
/// 0 represents "Instant / At deadline".
const List<int> kDefaultPresetDelays = [0, 15, 30, 60, 120, 1440];

/// Singleton managing user preferences (language, theme, notification delays).
class SettingsService extends ChangeNotifier {
  SettingsService._internal();
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;

  static const _keyLanguage = 'language';
  static const _keyTheme = 'theme_mode';
  static const _keyNotifDelays = 'notif_delays';
  static const _keyCustomDelays = 'custom_delays';

  // ── State ─────────────────────────────────────────────────────────────────

  /// 'fr', 'en', or 'system'
  String _language = 'system';
  String get language => _language;

  /// 'light', 'dark', or 'system'
  String _themeMode = 'system';
  String get themeMode => _themeMode;

  /// Set of active (checked) notification delays in minutes before deadline.
  Set<int> _notifDelays = {0, 60, 1440};
  Set<int> get notifDelays => Set.unmodifiable(_notifDelays);

  /// User-defined custom delays in minutes.
  List<int> _customDelays = [];
  List<int> get customDelays => List.unmodifiable(_customDelays);

  // ── Derived getters ───────────────────────────────────────────────────────

  /// True if current language is French (either explicit 'fr' or system is French).
  bool get isFrench {
    if (_language == 'fr') return true;
    if (_language == 'en') return false;
    final sysLang = ui.PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    return sysLang.startsWith('fr');
  }

  /// Helper for bilingual strings.
  String t(String fr, String en) => isFrench ? fr : en;

  Locale? get locale {
    switch (_language) {
      case 'fr':
        return const Locale('fr');
      case 'en':
        return const Locale('en');
      default:
        return null; // follows device locale
    }
  }

  ThemeMode get flutterThemeMode {
    switch (_themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // ── Delay Formatting ──────────────────────────────────────────────────────

  String formatDelayLabel(int minutes) {
    if (minutes == 0) {
      return isFrench ? 'Instantané (à l\'échéance)' : 'Instant (at deadline)';
    }
    if (minutes < 60) {
      return isFrench ? '$minutes min avant' : '$minutes min before';
    }
    if (minutes % 1440 == 0) {
      final days = minutes ~/ 1440;
      if (days == 1) {
        return isFrench ? '1 jour avant' : '1 day before';
      }
      return isFrench ? '$days jours avant' : '$days days before';
    }
    if (minutes % 60 == 0) {
      final hours = minutes ~/ 60;
      if (hours == 1) {
        return isFrench ? '1 heure avant' : '1 hour before';
      }
      return isFrench ? '$hours heures avant' : '$hours hours before';
    }
    final hours = minutes ~/ 60;
    final rem = minutes % 60;
    return isFrench ? '${hours}h ${rem}min avant' : '${hours}h ${rem}m before';
  }

  String formatDelayNotificationBody(int minutes) {
    if (minutes == 0) {
      return isFrench
          ? 'Votre tâche a atteint sa deadline'
          : 'Your task has reached its deadline';
    }
    if (minutes < 60) {
      return isFrench
          ? 'Deadline dans $minutes min'
          : 'Deadline in $minutes min';
    }
    if (minutes % 1440 == 0) {
      final days = minutes ~/ 1440;
      if (days == 1) {
        return isFrench ? 'Deadline dans 1 jour' : 'Deadline in 1 day';
      }
      return isFrench ? 'Deadline dans $days jours' : 'Deadline in $days days';
    }
    if (minutes % 60 == 0) {
      final hours = minutes ~/ 60;
      if (hours == 1) {
        return isFrench ? 'Deadline dans 1 heure' : 'Deadline in 1 hour';
      }
      return isFrench
          ? 'Deadline dans $hours heures'
          : 'Deadline in $hours hours';
    }
    final hours = minutes ~/ 60;
    final rem = minutes % 60;
    return isFrench
        ? 'Deadline dans ${hours}h ${rem}min'
        : 'Deadline in ${hours}h ${rem}m';
  }

  // ── Load / Save ───────────────────────────────────────────────────────────

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _language = prefs.getString(_keyLanguage) ?? 'system';
    _themeMode = prefs.getString(_keyTheme) ?? 'system';

    final savedNotifs = prefs.getStringList(_keyNotifDelays);
    if (savedNotifs != null && savedNotifs.isNotEmpty) {
      _notifDelays = savedNotifs.map(int.parse).toSet();
    }

    final savedCustom = prefs.getStringList(_keyCustomDelays);
    if (savedCustom != null) {
      _customDelays = savedCustom.map(int.parse).toList();
      _customDelays.sort();
    }

    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, lang);
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, mode);
    notifyListeners();
  }

  Future<void> toggleNotifDelay(int minutes) async {
    if (_notifDelays.contains(minutes)) {
      _notifDelays.remove(minutes);
    } else {
      _notifDelays.add(minutes);
    }
    await _saveNotifDelays();
    notifyListeners();
  }

  Future<void> addCustomDelay(int minutes) async {
    if (minutes <= 0) return;
    if (!_customDelays.contains(minutes) && !kDefaultPresetDelays.contains(minutes)) {
      _customDelays.add(minutes);
      _customDelays.sort();
      _notifDelays.add(minutes); // enabled by default
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _keyCustomDelays,
        _customDelays.map((e) => e.toString()).toList(),
      );
      await _saveNotifDelays();
      notifyListeners();
    } else if (!_notifDelays.contains(minutes)) {
      _notifDelays.add(minutes);
      await _saveNotifDelays();
      notifyListeners();
    }
  }

  Future<void> removeCustomDelay(int minutes) async {
    _customDelays.remove(minutes);
    _notifDelays.remove(minutes);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _keyCustomDelays,
      _customDelays.map((e) => e.toString()).toList(),
    );
    await _saveNotifDelays();
    notifyListeners();
  }

  Future<void> _saveNotifDelays() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _keyNotifDelays,
      _notifDelays.map((e) => e.toString()).toList(),
    );
  }
}
