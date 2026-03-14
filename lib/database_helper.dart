import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
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
    const int dbVersion = 2;

    if (kIsWeb) {
      var factory = databaseFactoryFfiWeb;
      return await factory.openDatabase(
        'store.db',
        options: OpenDatabaseOptions(
          version: dbVersion,
          onConfigure: _onConfigure,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        ),
      );
    }

    String path = join(await getDatabasesPath(), 'store.db');

    return await openDatabase(
      path,
      version: dbVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE stores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        prefecture TEXT,
        city TEXT,
        storeName TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE store_tags (
        store_id INTEGER,
        tag_id INTEGER,
        PRIMARY KEY (store_id, tag_id),
        FOREIGN KEY (store_id) REFERENCES stores (id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
      )
    ''');
    
    // 初期タグデータ作成
    final initialTags = ['がっつり', '軽食', 'コーヒー', 'スイーツ', '美術・博物館', '観光', 'お土産'];
    for (var tag in initialTags) {
      await db.insert('tags', {'name': tag});
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE stores ADD COLUMN city TEXT DEFAULT ''");
      
      await db.execute('''
        CREATE TABLE tags (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT UNIQUE NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE store_tags (
          store_id INTEGER,
          tag_id INTEGER,
          PRIMARY KEY (store_id, tag_id),
          FOREIGN KEY (store_id) REFERENCES stores (id) ON DELETE CASCADE,
          FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
        )
      ''');
      
      final initialTags = ['がっつり', '軽食', 'コーヒー', 'スイーツ', '美術・博物館', '観光', 'お土産'];
      for (var tag in initialTags) {
        await db.insert('tags', {'name': tag});
      }
    }
  }

  // データ挿入
  Future<int> insertStore(String prefecture, String city, String storeName) async {
    final db = await database;
    return await db.insert(
      'stores',
      {'prefecture': prefecture, 'city': city, 'storeName': storeName},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // データとタグの同時挿入
  Future<int> insertStoreWithTags(String prefecture, String city, String storeName, List<int> tagIds) async {
    final db = await database;
    return await db.transaction((txn) async {
      int storeId = await txn.insert(
        'stores',
        {'prefecture': prefecture, 'city': city, 'storeName': storeName},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      for (int tagId in tagIds) {
        await txn.insert(
          'store_tags',
          {'store_id': storeId, 'tag_id': tagId},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      return storeId;
    });
  }

  // データ取得
  Future<List<Map<String, dynamic>>> getStores() async {
    final db = await database;
    return await db.query('stores');
  }

  // データとタグを取得
  Future<List<Map<String, dynamic>>> getStoresWithTags() async {
    final db = await database;
    final stores = await db.query('stores');
    
    final storeTags = await db.rawQuery('''
      SELECT st.store_id, t.id as tag_id, t.name as tag_name 
      FROM store_tags st 
      JOIN tags t ON st.tag_id = t.id
    ''');
    
    Map<int, List<Map<String, dynamic>>> tagsMap = {};
    for (var row in storeTags) {
      int storeId = row['store_id'] as int;
      tagsMap.putIfAbsent(storeId, () => []);
      tagsMap[storeId]!.add({'id': row['tag_id'], 'name': row['tag_name']});
    }
    
    List<Map<String, dynamic>> results = [];
    for (var store in stores) {
      final mutableStore = Map<String, dynamic>.from(store);
      mutableStore['tags'] = tagsMap[store['id']] ?? [];
      results.add(mutableStore);
    }
    return results;
  }

  // 全タグ取得
  Future<List<Map<String, dynamic>>> getAllTags() async {
    final db = await database;
    return await db.query('tags');
  }

  // データ削除
  Future<int> deleteStore(int id) async {
    final db = await database;
    return await db.delete('stores', where: 'id = ?', whereArgs: [id]);
  }
}