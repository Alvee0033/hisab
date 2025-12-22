import 'package:flutter/material.dart';
import '../services/hive_service.dart';

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Default to light
  Locale _locale = const Locale('en');
  double _salaryAmount = 0.0;
  int _salaryDate = 1; // Default to 1st of the month
  bool _isSalaryEnabled = false;
  int _billingCycleStartDay = 1; // Default to 1st of the month
  bool _isBillingCycleEnabled = false;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  double get salaryAmount => _salaryAmount;
  int get salaryDate => _salaryDate;
  bool get isSalaryEnabled => _isSalaryEnabled;
  int get billingCycleStartDay => _billingCycleStartDay;
  bool get isBillingCycleEnabled => _isBillingCycleEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  void _loadSettings() {
    final box = HiveService.getSettingsBox();
    final isDark = box.get('isDark');
    final languageCode = box.get('languageCode');
    final salary = box.get('salaryAmount');
    final date = box.get('salaryDate');
    final enabled = box.get('isSalaryEnabled');
    final billingDay = box.get('billingCycleStartDay');
    final billingEnabled = box.get('isBillingCycleEnabled');

    if (isDark != null) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    } else {
      _themeMode = ThemeMode.light; // Force light default
    }

    if (languageCode != null) {
      _locale = Locale(languageCode);
    }
    
    if (salary != null) _salaryAmount = salary;
    if (date != null) _salaryDate = date;
    if (enabled != null) _isSalaryEnabled = enabled;
    if (billingDay != null) _billingCycleStartDay = billingDay;
    if (billingEnabled != null) _isBillingCycleEnabled = billingEnabled;

    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    final box = HiveService.getSettingsBox();
    await box.put('isDark', isDark);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final box = HiveService.getSettingsBox();
    await box.put('languageCode', locale.languageCode);
    notifyListeners();
  }

  Future<void> setBillingCycleStartDay(int day) async {
    _billingCycleStartDay = day;
    final box = HiveService.getSettingsBox();
    await box.put('billingCycleStartDay', day);
    notifyListeners();
  }

  Future<void> setSalarySettings({required double amount, required int date, required bool enabled}) async {
    _salaryAmount = amount;
    _salaryDate = date;
    _isSalaryEnabled = enabled;
    
    final box = HiveService.getSettingsBox();
    await box.put('salaryAmount', amount);
    await box.put('salaryDate', date);
    await box.put('isSalaryEnabled', enabled);
    notifyListeners();
  }

  Future<void> setBillingCycle(int day, bool enabled) async {
    _billingCycleStartDay = day;
    _isBillingCycleEnabled = enabled;
    final box = HiveService.getSettingsBox();
    await box.put('billingCycleStartDay', day);
    await box.put('isBillingCycleEnabled', enabled);
    notifyListeners();
  }
}
