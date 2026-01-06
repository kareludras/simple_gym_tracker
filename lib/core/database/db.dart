import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'migrations.dart';
import '../constants/database_constants.dart';

/// Service for managing SQLite database connection and lifecycle
class DatabaseService {
  Database? _databaseInstance;

  /// Gets the database instance, initializing it if necessary
  Future<Database> get database async {
    if (_databaseInstance != null) return _databaseInstance!;

    _databaseInstance = await _initializeDatabase();
    return _databaseInstance!;
  }

  Future<Database> _initializeDatabase() async {
    final databasePath = await _getDatabasePath();

    return await openDatabase(
      databasePath,
      version: DatabaseConstants.databaseVersion,
      onCreate: Migrations.onCreate,
      onUpgrade: Migrations.onUpgrade,
    );
  }

  Future<String> _getDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, DatabaseConstants.databaseName);
  }

  /// Closes the database connection
  Future<void> closeDatabaseConnection() async {
    if (_databaseInstance != null) {
      await _databaseInstance!.close();
      _databaseInstance = null;
    }
  }

  /// Deletes the database file (used for testing or data reset)
  Future<void> deleteDatabaseFile() async {
    final databasePath = await _getDatabasePath();
    await deleteDatabase(databasePath);
    _databaseInstance = null;
  }
}

/// Provider for database service
final databaseProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});
