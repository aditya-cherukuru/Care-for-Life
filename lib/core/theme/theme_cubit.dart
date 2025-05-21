import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:care_for_life/core/utils/shared_prefs.dart';

// Theme State
class ThemeState {
  final ThemeMode themeMode;

  const ThemeState({required this.themeMode});

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

// Theme Cubit
class ThemeCubit extends Cubit<ThemeState> {
  final SharedPrefs _prefsHelper;

  ThemeCubit(this._prefsHelper)
      : super(ThemeState(
          themeMode: SharedPrefs.getThemeMode(),
        ));

  void setThemeMode(ThemeMode themeMode) {
    SharedPrefs.saveThemeMode(themeMode);
    emit(state.copyWith(themeMode: themeMode));
  }

  void toggleTheme() {
    final newThemeMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    setThemeMode(newThemeMode);
  }
}