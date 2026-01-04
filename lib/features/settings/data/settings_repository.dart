import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum WeightUnit { kg, lb }

class SettingsRepository {
  static const String _keyWeightUnit = 'weight_unit';
  static const String _keyThemeMode = 'theme_mode';

  Future<WeightUnit> getWeightUnit() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyWeightUnit) ?? 'kg';
    return value == 'lb' ? WeightUnit.lb : WeightUnit.kg;
  }

  Future<void> setWeightUnit(WeightUnit unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyWeightUnit, unit.name);
  }

  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyThemeMode) ?? 'system';
    return ThemeMode.values.firstWhere(
          (e) => e.name == value,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode.name);
  }
}