import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final weightUnitProvider = StateNotifierProvider<WeightUnitNotifier, WeightUnit>((ref) {
  return WeightUnitNotifier(ref.watch(settingsRepositoryProvider));
});

class WeightUnitNotifier extends StateNotifier<WeightUnit> {
  final SettingsRepository _repo;

  WeightUnitNotifier(this._repo) : super(WeightUnit.kg) {
    _loadUnit();
  }

  Future<void> _loadUnit() async {
    state = await _repo.getWeightUnit();
  }

  Future<void> setUnit(WeightUnit unit) async {
    await _repo.setWeightUnit(unit);
    state = unit;
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.watch(settingsRepositoryProvider));
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SettingsRepository _repo;

  ThemeModeNotifier(this._repo) : super(ThemeMode.system) {
    _loadMode();
  }

  Future<void> _loadMode() async {
    state = await _repo.getThemeMode();
  }

  Future<void> setMode(ThemeMode mode) async {
    await _repo.setThemeMode(mode);
    state = mode;
  }
}