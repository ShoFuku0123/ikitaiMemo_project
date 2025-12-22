import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_helper.dart';
import 'add_page.dart';

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<Map<String, dynamic>> _storeList = [];
  List<Map<String, dynamic>> _filteredStoreList = [];
  String? _selectedPrefecture;
  bool _isExpanded = false; // FABの展開状態

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
      body: Column(
        children: [
          // 都道府県フィルタリング用ドロップダウン
          Container(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.6),
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
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
                ? Center(
                    child: Text(
                      'まずは右下のボタンから\n追加してみよう！',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
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
      floatingActionButton: MouseRegion(
        onEnter: (_) => setState(() => _isExpanded = true),
        onExit: (_) => setState(() => _isExpanded = false),
        child: GestureDetector(
          onTap: () async {
            // macOS/Webなどのデスクトップ環境、または既に展開されている場合は遷移
            // それ以外（モバイルの1回目タップ）は展開のみ
            final bool isDesktop = Theme.of(context).platform == TargetPlatform.macOS || 
                                 Theme.of(context).platform == TargetPlatform.windows || 
                                 Theme.of(context).platform == TargetPlatform.linux;

            if (isDesktop || _isExpanded) {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AddPage()),
              );
              _loadStores();
              setState(() => _isExpanded = false);
            } else {
              setState(() => _isExpanded = true);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: 65,
            width: _isExpanded ? 180 : 65,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, color: Colors.white, size: 30),
                if (_isExpanded)
                  const Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        '新規追加！',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
