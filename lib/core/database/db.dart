import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'migrations.dart';
import '../constants/database_constants.dart';

class DatabaseService {
  Database? _databaseInstance;

  Future<Database> get database async {
    if (_databaseInstance != null) return _databaseInstance!;

    _databaseInstance = await _initializeDatabase();
    return _databaseInstance!;
  }

  Future<Database> _initializeDatabase() async {
    if (kIsWeb) {
      debugPrint('Opening in-memory database for web...');
      final db = await openDatabase(
        inMemoryDatabasePath,
        version: DatabaseConstants.databaseVersion,
        onCreate: Migrations.onCreate,
      );
      debugPrint('In-memory database opened successfully');
      return db;
    } else {
      final databasePath = await _getDatabasePath();
      return await openDatabase(
        databasePath,
        version: DatabaseConstants.databaseVersion,
        onCreate: Migrations.onCreate,
        onUpgrade: Migrations.onUpgrade,
      );
    }
  }

  Future<String> _getDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, DatabaseConstants.databaseName);
  }

  Future<void> closeDatabaseConnection() async {
    if (_databaseInstance != null) {
      await _databaseInstance!.close();
      _databaseInstance = null;
    }
  }

  Future<void> deleteDatabaseFile() async {
    if (kIsWeb) {
      await closeDatabaseConnection();
      _databaseInstance = null;
    } else {
      final databasePath = await _getDatabasePath();
      await deleteDatabase(databasePath);
      _databaseInstance = null;
    }
  }
}

final databaseProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});
