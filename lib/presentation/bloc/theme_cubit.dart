import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/local_database.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final LocalDatabase _localDb;

  ThemeCubit(this._localDb) : super(_getInitialTheme(_localDb));

  static ThemeMode _getInitialTheme(LocalDatabase db) {
    final themeStr = db.getThemeMode();
    return themeStr == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _localDb.setThemeMode(newMode == ThemeMode.dark ? 'dark' : 'light');
    emit(newMode);
  }

  void setTheme(ThemeMode mode) {
    _localDb.setThemeMode(mode == ThemeMode.dark ? 'dark' : 'light');
    emit(mode);
  }
}
