import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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