import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    if (kIsWeb) {
      // For web, use the sqflite_common_ffi_web factory
      var factory = databaseFactoryFfiWeb;
      return await factory.openDatabase(
        'store.db',
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute('''
          CREATE TABLE stores (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            prefecture TEXT,
            storeName TEXT
          )
        ''');
          },
        ),
      );
    }

    String path = join(await getDatabasesPath(), 'store.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE stores (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            prefecture TEXT,
            storeName TEXT
          )
        ''');
      },
    );
  }

  // データ挿入
  Future<int> insertStore(String prefecture, String storeName) async {
    final db = await database;
    return await db.insert(
      'stores',
      {'prefecture': prefecture, 'storeName': storeName},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // データ取得
  Future<List<Map<String, dynamic>>> getStores() async {
    final db = await database;
    return await db.query('stores');
  }

  // データ削除
  Future<int> deleteStore(int id) async {
    final db = await database;
    return await db.delete('stores', where: 'id = ?', whereArgs: [id]);
  }
}