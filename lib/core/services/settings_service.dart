import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  SettingsService(this._prefs);

  final SharedPreferences _prefs;

  static const _keyThemeMode = 'theme_mode';
  static const _keyPinCode = 'pin_code';
  static const _keyPinEnabled = 'pin_enabled';
  static const _keyBiometricEnabled = 'biometric_enabled';
  static const _keyDailyReminderEnabled = 'daily_reminder_enabled';
  static const _keyDailyReminderHour = 'daily_reminder_hour';
  static const _keyDailyReminderMinute = 'daily_reminder_minute';

  String get themeMode => _prefs.getString(_keyThemeMode) ?? 'system';

  Future<void> setThemeMode(String value) =>
      _prefs.setString(_keyThemeMode, value);

  String? get pinCode => _prefs.getString(_keyPinCode);

  Future<void> setPinCode(String? value) {
    if (value == null) {
      return _prefs.remove(_keyPinCode);
    }
    return _prefs.setString(_keyPinCode, value);
  }

  bool get isPinEnabled => _prefs.getBool(_keyPinEnabled) ?? false;

  Future<void> setPinEnabled(bool value) =>
      _prefs.setBool(_keyPinEnabled, value);

  bool get isBiometricEnabled => _prefs.getBool(_keyBiometricEnabled) ?? false;

  Future<void> setBiometricEnabled(bool value) =>
      _prefs.setBool(_keyBiometricEnabled, value);

  bool get isDailyReminderEnabled =>
      _prefs.getBool(_keyDailyReminderEnabled) ?? false;

  Future<void> setDailyReminderEnabled(bool value) =>
      _prefs.setBool(_keyDailyReminderEnabled, value);

  int get dailyReminderHour => _prefs.getInt(_keyDailyReminderHour) ?? 21;

  int get dailyReminderMinute => _prefs.getInt(_keyDailyReminderMinute) ?? 0;

  Future<void> setDailyReminderTime(int hour, int minute) async {
    await _prefs.setInt(_keyDailyReminderHour, hour);
    await _prefs.setInt(_keyDailyReminderMinute, minute);
  }
}
