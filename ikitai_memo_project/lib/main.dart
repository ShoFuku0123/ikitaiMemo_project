import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.initDatabase();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ikitai Memo App',
      home: ListPage(),
    );
  }
}

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<Map<String, dynamic>> _storeList = [];
  List<Map<String, dynamic>> _filteredStoreList = [];
  String? _selectedPrefecture;

  // 都道府県リスト
  final List<String> _prefectures = [
    'すべて',
    '北海道', '青森', '岩手', '宮城', '秋田', '山形', '福島',
    '茨城', '栃木', '群馬', '埼玉', '千葉', '東京', '神奈川',
    '新潟', '富山', '石川', '福井', '山梨', '長野', '岐阜',
    '静岡', '愛知', '三重', '滋賀', '京都', '大阪', '兵庫',
    '奈良', '和歌山', '鳥取', '島根', '岡山', '広島', '山口',
    '徳島', '香川', '愛媛', '高知', '福岡', '佐賀', '長崎',
    '熊本', '大分', '宮崎', '鹿児島', '沖縄'
  ];

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    final data = await DatabaseHelper.instance.getStores();
    setState(() {
      _storeList = data;
      _filterStores();
    });
  }

  Future<void> _deleteStore(int id) async {
    await DatabaseHelper.instance.deleteStore(id);
    _loadStores(); // 削除後にリストを更新
  }

  void _filterStores() {
    setState(() {
      if (_selectedPrefecture == null || _selectedPrefecture == 'すべて') {
        _filteredStoreList = List.from(_storeList);
      } else {
        _filteredStoreList = _storeList
            .where((store) => store['prefecture'] == _selectedPrefecture)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 75,
        flexibleSpace: Image.asset(
          'images/AppBar.jpg',
          fit: BoxFit.fitWidth,
        ),
        title: Text(
          '行きたいメモ',
          style: GoogleFonts.yuseiMagic(
            color: Color.fromARGB(255, 0, 0, 0),
            fontSize: 52,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Color.fromARGB(255, 255, 219, 192),
      body: Column(
        children: [
          // 都道府県フィルタリング用ドロップダウン
          Container(
            color: Color.fromARGB(159, 255, 187, 113),
            padding: const EdgeInsets.fromLTRB(30.0, 0, 280.0, 8.0),
            child: DropdownButton<String>(
              underline: Container(
                height: 1.0,
                color: Colors.black,
              ),
              style: TextStyle(
                fontSize: 22.0,
                color: Colors.black,
              ),
              isExpanded: true,
              value: _selectedPrefecture ?? 'すべて',
              items: _prefectures.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPrefecture = value;
                  _filterStores(); // 絞り込み
                });
              },
            ),
          ),
          Expanded(
            child: _filteredStoreList.isEmpty
                ? Center(child: Text('右下のボタンから追加だよ〜'))
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 0),
                    itemCount: _filteredStoreList.length,
                    itemBuilder: (context, index) {
                      final store = _filteredStoreList[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                              '${store['prefecture']}： ${store['storeName']}'),
                              titleTextStyle: TextStyle(
                                fontSize: 20.0,
                                color: const Color.fromARGB(255, 22, 22, 22),
                              ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteStore(store['id']),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(height: 27.0),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return AddPage();
            })
          );
          _loadStores(); // データ追加後にリストを更新
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddPage extends StatefulWidget {
  @override
  _AddPageState createState() => _AddPageState();
}

// 追加ページ
class _AddPageState extends State<AddPage> {
  // フォーム入力のキーを定義
  final formKey = GlobalKey<FormState>();

  String prefecture = '';
  String storeName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 75,
        flexibleSpace: Image.asset(
          'images/AppBar.jpg',
          fit: BoxFit.fitWidth,
        ),
        title: Text(
          '行きたいメモ',
          style: GoogleFonts.yuseiMagic(
            color: Color.fromARGB(255, 0, 0, 0),
            fontSize: 52,
          ),
        ),
        centerTitle: true,
      ),
      // バックグラウンドカラー
      backgroundColor: Color.fromARGB(255, 253, 220, 195),
      body: Container(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // 都道府県
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 80.0, 16.0, 16.0),
                // 都道府県入力フィールド
                child: TextFormField(
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  decoration: const InputDecoration(
                    labelText: '都道府県',
                    labelStyle: TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(140, 0, 0, 0)
                    ),
                    hintText: '例】 東京（都府県は無し）',
                    hintStyle: TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(140, 0, 0, 0)
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 2.0,
                        color: Color.fromARGB(255, 91, 160, 210),
                      ),
                    ),
                  ),
                  // バリデーション（Null許容しない＆漢字以外許容しない
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '入力してください';
                    }
                    if (!RegExp(r'^[一-龥々]+$').hasMatch(value)) {
                      return '漢字で入力してください';
                    }
                    return null;
                  },
                  onSaved: (value){
                    prefecture = value ?? '';
                  },
                ),
              ),
              // 店名
              Padding(
                padding: const EdgeInsets.all(16.0),
                // 店名入力フィールド
                child: TextFormField(
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  decoration: const InputDecoration(
                    labelText: '施設名 or キーワード',
                    labelStyle: TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(140, 0, 0, 0)
                    ),
                    hintText: '例】 喫茶〇〇 本店',
                    hintStyle: TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(140, 0, 0, 0)
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 2.0,
                        color: Color.fromARGB(255, 91, 160, 210),
                      ),
                    )
                  ),
                  // バリデーション（Null許容しない
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '入力してください';
                    }
                    return null;
                  },
                  onSaved: (value){
                    storeName = value ?? '';
                  },
                ),
              ),
              const SizedBox(height: 48.0),
              // 追加ボタン
              Container(
                padding: const EdgeInsets.fromLTRB(64.0, 32.0, 64.0, 8.0),
                width: double.infinity,
                height: 100,
                child: ElevatedButton(
                  // 処理部分
                  onPressed: () async{
                    if (formKey.currentState!.validate()) {
                      formKey.currentState?.save();
                      await DatabaseHelper.instance.insertStore(
                        prefecture,
                        storeName,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          content: Text(
                            '〜〜追加完了〜〜',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return AddPage();
                        })
                      );
                    }
                  },
                  child: Text(
                    '追加 !!!',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white
                    ),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 255, 179, 92)),
                ),
              ),
              const SizedBox(height: 4.0),
              // ListPageに戻るボタン
              Container(
                padding: const EdgeInsets.fromLTRB(64.0, 8.0, 64.0, 32.0),
                width: double.infinity,
                height: 100,
                child: ElevatedButton(
                  onPressed: (){
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return ListPage();
                      })
                    );
                  },
                  child: Text(
                    'リストにもどる',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.blue,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 255, 255, 255)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// SQLiteにデータを保存・取得・削除するヘルパークラス
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