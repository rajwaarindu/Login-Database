import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('users.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        nim TEXT NOT NULL UNIQUE,
        alamat TEXT NOT NULL,
        no_wa TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<int> createUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUser(String nim, String password) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'nim = ? AND password = ?',
      whereArgs: [nim, password],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<bool> checkNimExists(String nim) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'nim = ?',
      whereArgs: [nim],
    );
    return results.isNotEmpty;
  }

  Future<bool> checkEmailExists(String email) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return results.isNotEmpty;
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}