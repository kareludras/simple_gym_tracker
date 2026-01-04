import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/settings_provider.dart';
import '../data/settings_repository.dart';
import '../../../core/database/db.dart';
import '../../../core/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightUnit = ref.watch(weightUnitProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Preferences',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            title: const Text('Weight Unit'),
            subtitle: Text(weightUnit == WeightUnit.kg ? 'Kilograms (kg)' : 'Pounds (lb)'),
            onTap: () => _showWeightUnitDialog(context, ref),
          ),
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(_getThemeModeLabel(themeMode)),
            onTap: () => _showThemeModeDialog(context, ref),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Data',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            title: const Text('Reset All Data'),
            subtitle: const Text('Delete all workouts and custom exercises'),
            textColor: Colors.red,
            onTap: () => _showResetDialog(context, ref),
          ),
        ],
      ),
    );
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showWeightUnitDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Weight Unit'),
        children: [
          SimpleDialogOption(
            child: const Text('Kilograms (kg)'),
            onPressed: () {
              ref.read(weightUnitProvider.notifier).setUnit(WeightUnit.kg);
              Navigator.pop(context);
            },
          ),
          SimpleDialogOption(
            child: const Text('Pounds (lb)'),
            onPressed: () {
              ref.read(weightUnitProvider.notifier).setUnit(WeightUnit.lb);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showThemeModeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Theme'),
        children: [
          SimpleDialogOption(
            child: const Text('Light'),
            onPressed: () {
              ref.read(themeModeProvider.notifier).setMode(ThemeMode.light);
              Navigator.pop(context);
            },
          ),
          SimpleDialogOption(
            child: const Text('Dark'),
            onPressed: () {
              ref.read(themeModeProvider.notifier).setMode(ThemeMode.dark);
              Navigator.pop(context);
            },
          ),
          SimpleDialogOption(
            child: const Text('System'),
            onPressed: () {
              ref.read(themeModeProvider.notifier).setMode(ThemeMode.system);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will permanently delete all your workouts and custom exercises. '
              'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final db = ref.read(databaseProvider);
              await db.deleteDb();
              ref.invalidate(workoutListProvider);
              ref.invalidate(exerciseListProvider);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data has been reset. Restart the app to reinitialize.'),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}