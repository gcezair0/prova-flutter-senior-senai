import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../database/app_database.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final AppDatabase _db;
  static const _themeKey = 'theme_mode';

  ThemeCubit(this._db) : super(ThemeMode.system);

  Future<void> loadTheme() async {
    final saved = await _db.settingsDao.getValue(_themeKey);

    if (saved == null) {
      emit(ThemeMode.system);
      return;
    }

    switch (saved) {
      case 'light':
        emit(ThemeMode.light);
      case 'dark':
        emit(ThemeMode.dark);
      default:
        emit(ThemeMode.system);
    }
  }

  Future<void> toggleTheme() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _db.settingsDao.setValue(_themeKey, next == ThemeMode.dark ? 'dark' : 'light');
    emit(next);
  }
}