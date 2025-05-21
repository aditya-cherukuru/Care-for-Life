import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A utility class to handle shared preferences operations
class SharedPrefs {
  static SharedPreferences? _prefs;
  
  // Keys for shared preferences
  static const String _themeKey = 'theme_mode';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _lastSyncKey = 'last_sync';
  
  /// Initialize shared preferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  /// Get the saved theme mode
  static ThemeMode getThemeMode() {
    final themeValue = _prefs?.getString(_themeKey);
    
    if (themeValue == null) {
      return ThemeMode.system;
    }
    
    switch (themeValue) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
  
  /// Save the theme mode
  static Future<bool> saveThemeMode(ThemeMode mode) async {
    String themeValue;
    
    switch (mode) {
      case ThemeMode.light:
        themeValue = 'light';
        break;
      case ThemeMode.dark:
        themeValue = 'dark';
        break;
      case ThemeMode.system:
        themeValue = 'system';
        break;
    }
    
    return await _prefs?.setString(_themeKey, themeValue) ?? false;
  }
  
  /// Check if onboarding has been completed
  static bool isOnboardingCompleted() {
    return _prefs?.getBool(_onboardingCompletedKey) ?? false;
  }
  
  /// Set onboarding as completed
  static Future<bool> setOnboardingCompleted() async {
    return await _prefs?.setBool(_onboardingCompletedKey, true) ?? false;
  }
  
  /// Get the last sync timestamp
  static DateTime? getLastSync() {
    final timestamp = _prefs?.getInt(_lastSyncKey);
    if (timestamp == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
  
  /// Save the last sync timestamp
  static Future<bool> saveLastSync(DateTime dateTime) async {
    return await _prefs?.setInt(
      _lastSyncKey, 
      dateTime.millisecondsSinceEpoch
    ) ?? false;
  }
  
  /// Save a string value
  static Future<bool> saveString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }
  
  /// Get a string value
  static String? getString(String key) {
    return _prefs?.getString(key);
  }
  
  /// Save a boolean value
  static Future<bool> saveBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }
  
  /// Get a boolean value
  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }
  
  /// Save an integer value
  static Future<bool> saveInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }
  
  /// Get an integer value
  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }
  
  /// Clear all preferences
  static Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }
}