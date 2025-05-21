import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// State
class SettingsState extends Equatable {
  final bool useMetricSystem;
  final bool use24HourTime;
  final String defaultTab;
  final bool startWeekOnMonday;
  final bool notificationsEnabled;
  final String reminderTime;
  final bool goalNotificationsEnabled;
  final bool weeklyReportsEnabled;
  final ThemeMode themeMode;
  final String accentColor;
  final bool useDynamicColors;

  const SettingsState({
    required this.useMetricSystem,
    required this.use24HourTime,
    required this.defaultTab,
    required this.startWeekOnMonday,
    required this.notificationsEnabled,
    required this.reminderTime,
    required this.goalNotificationsEnabled,
    required this.weeklyReportsEnabled,
    required this.themeMode,
    required this.accentColor,
    required this.useDynamicColors,
  });

  SettingsState copyWith({
    bool? useMetricSystem,
    bool? use24HourTime,
    String? defaultTab,
    bool? startWeekOnMonday,
    bool? notificationsEnabled,
    String? reminderTime,
    bool? goalNotificationsEnabled,
    bool? weeklyReportsEnabled,
    ThemeMode? themeMode,
    String? accentColor,
    bool? useDynamicColors,
  }) {
    return SettingsState(
      useMetricSystem: useMetricSystem ?? this.useMetricSystem,
      use24HourTime: use24HourTime ?? this.use24HourTime,
      defaultTab: defaultTab ?? this.defaultTab,
      startWeekOnMonday: startWeekOnMonday ?? this.startWeekOnMonday,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      goalNotificationsEnabled: goalNotificationsEnabled ?? this.goalNotificationsEnabled,
      weeklyReportsEnabled: weeklyReportsEnabled ?? this.weeklyReportsEnabled,
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      useDynamicColors: useDynamicColors ?? this.useDynamicColors,
    );
  }

  @override
  List<Object?> get props => [
        useMetricSystem,
        use24HourTime,
        defaultTab,
        startWeekOnMonday,
        notificationsEnabled,
        reminderTime,
        goalNotificationsEnabled,
        weeklyReportsEnabled,
        themeMode,
        accentColor,
        useDynamicColors,
      ];

  // Default settings
  factory SettingsState.initial() {
    return const SettingsState(
      useMetricSystem: true,
      use24HourTime: false,
      defaultTab: 'Dashboard',
      startWeekOnMonday: false,
      notificationsEnabled: true,
      reminderTime: '20:00',
      goalNotificationsEnabled: true,
      weeklyReportsEnabled: true,
      themeMode: ThemeMode.system,
      accentColor: 'Blue',
      useDynamicColors: true,
    );
  }

  // Keys for SharedPreferences
  static const String _useMetricSystemKey = 'use_metric_system';
  static const String _use24HourTimeKey = 'use_24_hour_time';
  static const String _defaultTabKey = 'default_tab';
  static const String _startWeekOnMondayKey = 'start_week_on_monday';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _reminderTimeKey = 'reminder_time';
  static const String _goalNotificationsEnabledKey = 'goal_notifications_enabled';
  static const String _weeklyReportsEnabledKey = 'weekly_reports_enabled';
  static const String _themeModeKey = 'theme_mode';
  static const String _accentColorKey = 'accent_color';
  static const String _useDynamicColorsKey = 'use_dynamic_colors';

  // Load settings from SharedPreferences
  static Future<SettingsState> fromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    return SettingsState(
      useMetricSystem: prefs.getBool(_useMetricSystemKey) ?? true,
      use24HourTime: prefs.getBool(_use24HourTimeKey) ?? false,
      defaultTab: prefs.getString(_defaultTabKey) ?? 'Dashboard',
      startWeekOnMonday: prefs.getBool(_startWeekOnMondayKey) ?? false,
      notificationsEnabled: prefs.getBool(_notificationsEnabledKey) ?? true,
      reminderTime: prefs.getString(_reminderTimeKey) ?? '20:00',
      goalNotificationsEnabled: prefs.getBool(_goalNotificationsEnabledKey) ?? true,
      weeklyReportsEnabled: prefs.getBool(_weeklyReportsEnabledKey) ?? true,
      themeMode: ThemeMode.values[prefs.getInt(_themeModeKey) ?? 0],
      accentColor: prefs.getString(_accentColorKey) ?? 'Blue',
      useDynamicColors: prefs.getBool(_useDynamicColorsKey) ?? true,
    );
  }

  // Save settings to SharedPreferences
  Future<void> saveToSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool(_useMetricSystemKey, useMetricSystem);
    await prefs.setBool(_use24HourTimeKey, use24HourTime);
    await prefs.setString(_defaultTabKey, defaultTab);
    await prefs.setBool(_startWeekOnMondayKey, startWeekOnMonday);
    await prefs.setBool(_notificationsEnabledKey, notificationsEnabled);
    await prefs.setString(_reminderTimeKey, reminderTime);
    await prefs.setBool(_goalNotificationsEnabledKey, goalNotificationsEnabled);
    await prefs.setBool(_weeklyReportsEnabledKey, weeklyReportsEnabled);
    await prefs.setInt(_themeModeKey, themeMode.index);
    await prefs.setString(_accentColorKey, accentColor);
    await prefs.setBool(_useDynamicColorsKey, useDynamicColors);
  }
}

// Cubit
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsState.initial()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsState.fromSharedPreferences();
    emit(settings);
  }

  Future<void> _saveSettings() async {
    await state.saveToSharedPreferences();
  }

  void setUseMetricSystem(bool value) {
    emit(state.copyWith(useMetricSystem: value));
    _saveSettings();
  }

  void toggleUse24HourTime() {
    emit(state.copyWith(use24HourTime: !state.use24HourTime));
    _saveSettings();
  }

  void setDefaultTab(String tab) {
    emit(state.copyWith(defaultTab: tab));
    _saveSettings();
  }

  void toggleStartWeekOnMonday() {
    emit(state.copyWith(startWeekOnMonday: !state.startWeekOnMonday));
    _saveSettings();
  }

  void toggleNotifications() {
    final newValue = !state.notificationsEnabled;
    emit(state.copyWith(
      notificationsEnabled: newValue,
      // If notifications are disabled, also disable these
      goalNotificationsEnabled: newValue ? state.goalNotificationsEnabled : false,
      weeklyReportsEnabled: newValue ? state.weeklyReportsEnabled : false,
    ));
    _saveSettings();
  }

  void setReminderTime(String time) {
    emit(state.copyWith(reminderTime: time));
    _saveSettings();
  }

  void toggleGoalNotifications() {
    emit(state.copyWith(goalNotificationsEnabled: !state.goalNotificationsEnabled));
    _saveSettings();
  }

  void toggleWeeklyReports() {
    emit(state.copyWith(weeklyReportsEnabled: !state.weeklyReportsEnabled));
    _saveSettings();
  }

  void setThemeMode(ThemeMode mode) {
    emit(state.copyWith(themeMode: mode));
    _saveSettings();
  }

  void setAccentColor(String color) {
    emit(state.copyWith(accentColor: color));
    _saveSettings();
  }

  void toggleDynamicColors() {
    emit(state.copyWith(useDynamicColors: !state.useDynamicColors));
    _saveSettings();
  }

  void resetToDefaults() {
    emit(SettingsState.initial());
    _saveSettings();
  }
}