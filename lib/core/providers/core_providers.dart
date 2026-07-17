import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/app_database.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('باید در main.dart مقداردهی اولیه شود');
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService(ref.watch(sharedPreferencesProvider));
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

enum AppThemeMode { light, dark, system }

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, AppThemeMode>((ref) {
  return ThemeModeNotifier(ref.watch(settingsServiceProvider));
});

class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  ThemeModeNotifier(this._settings) : super(_fromString(_settings.themeMode));

  final SettingsService _settings;

  static AppThemeMode _fromString(String value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      default:
        return AppThemeMode.system;
    }
  }

  Future<void> setMode(AppThemeMode mode) async {
    state = mode;
    await _settings.setThemeMode(mode.name);
  }
}
