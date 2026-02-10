import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/local_database.dart';

class ThemeCubit extends Cubit<String> {
  final LocalDatabase _localDb;

  ThemeCubit(this._localDb) : super(_localDb.getThemeMode());

  void toggleTheme() {
    final current = state;
    // Simple toggle between classic light and dark for now
    // If we want to support other packs, we'd need more logic
    final next = current.contains('dark') || current.contains('night')
        ? 'classic_light'
        : 'classic_dark';
    setTheme(next);
  }

  void setTheme(String themeKey) {
    _localDb.setThemeMode(themeKey);
    emit(themeKey);
  }
}
