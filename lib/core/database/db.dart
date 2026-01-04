import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'migrations.dart';

class DatabaseService {
  static const String _dbName = 'gym_tracker.db';
  static const int _dbVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: Migrations.onCreate,
      onUpgrade: Migrations.onUpgrade,
    );
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> deleteDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    await deleteDatabase(path);
    _database = null;
  }
}

final databaseProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});