import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/local_database.dart';

class ThemeCubit extends Cubit<String> {
  final LocalDatabase _localDb;

  ThemeCubit(this._localDb) : super(_localDb.getThemeMode());

  void toggleTheme() {
    final current = state;
    final next = current == 'light' ? 'dark' : 'light';
    setTheme(next);
  }

  void setTheme(String themeKey) {
    _localDb.setThemeMode(themeKey);
    emit(themeKey);
  }
}
