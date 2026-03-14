import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database_helper.dart';
import 'add_page.dart';

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<Map<String, dynamic>> _storeList = [];
  List<Map<String, dynamic>> _filteredStoreList = [];
  
  List<Map<String, dynamic>> _allTags = [];
  
  String? _selectedPrefecture;
  List<String> _availableCities = [];
  List<String> _selectedCities = [];
  List<int> _selectedTagIds = [];

  final List<String> _prefectures = [
    'すべて', '北海道', '青森県', '岩手県', '宮城県', '秋田県', '山形県', '福島県',
    '茨城県', '栃木県', '群馬県', '埼玉県', '千葉県', '東京都', '神奈川県',
    '新潟県', '富山県', '石川県', '福井県', '山梨県', '長野県', '岐阜県',
    '静岡県', '愛知県', '三重県', '滋賀県', '京都府', '大阪府', '兵庫県',
    '奈良県', '和歌山県', '鳥取県', '島根県', '岡山県', '広島県', '山口県',
    '徳島県', '香川県', '愛媛県', '高知県', '福岡県', '佐賀県', '長崎県',
    '熊本県', '大分県', '宮崎県', '鹿児島県', '沖縄県'
  ];

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    final data = await DatabaseHelper.instance.getStoresWithTags();
    final tagsData = await DatabaseHelper.instance.getAllTags();
    setState(() {
      _storeList = data;
      _allTags = tagsData;
      _updateAvailableCities();
      _filterStores();
    });
  }

  void _updateAvailableCities() {
    _selectedCities.clear();
    if (_selectedPrefecture == null || _selectedPrefecture == 'すべて') {
      _availableCities = [];
    } else {
      _availableCities = _storeList
          .where((s) => s['prefecture'] == _selectedPrefecture && s['city'] != null && s['city'].toString().isNotEmpty)
          .map((s) => s['city'] as String)
          .toSet()
          .toList();
      _availableCities.sort();
    }
  }

  Future<void> _deleteStore(int id) async {
    await DatabaseHelper.instance.deleteStore(id);
    _loadStores();
  }

  void _filterStores() {
    setState(() {
      _filteredStoreList = _storeList.where((store) {
        // 都道府県フィルタ
        if (_selectedPrefecture != null && _selectedPrefecture != 'すべて') {
          if (store['prefecture'] != _selectedPrefecture) return false;
        }
        
        // 市区町村フィルタ
        if (_selectedCities.isNotEmpty) {
          if (!store.containsKey('city') || !_selectedCities.contains(store['city'])) return false;
        }
        
        // タグフィルタ (AND検索)
        if (_selectedTagIds.isNotEmpty) {
          final storeTags = (store['tags'] as List).map((t) => t['id'] as int).toList();
          for (var tagId in _selectedTagIds) {
            if (!storeTags.contains(tagId)) return false;
          }
        }
        
        return true;
      }).toList();
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 都道府県フィルタ
          Container(
            color: Color.fromARGB(159, 255, 187, 113),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text('都道府県: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    underline: Container(height: 1.0, color: Colors.black),
                    style: TextStyle(fontSize: 20.0, color: Colors.black),
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
                        _updateAvailableCities();
                        _filterStores();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // 市区町村フィルタ
          if (_availableCities.isNotEmpty)
            Container(
              color: Color.fromARGB(100, 255, 187, 113),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _availableCities.map((city) {
                    final isSelected = _selectedCities.contains(city);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(city),
                        selected: isSelected,
                        selectedColor: Colors.orange.shade300,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedCities.add(city);
                            } else {
                              _selectedCities.remove(city);
                            }
                            _filterStores();
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // タグフィルタ
          if (_allTags.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Icon(Icons.local_offer, size: 20, color: Colors.grey[700]),
                    SizedBox(width: 8),
                    ..._allTags.map((tag) {
                      final isSelected = _selectedTagIds.contains(tag['id']);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(tag['name'] as String),
                          selected: isSelected,
                          selectedColor: Colors.blue.shade200,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTagIds.add(tag['id'] as int);
                              } else {
                                _selectedTagIds.remove(tag['id'] as int);
                              }
                              _filterStores();
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

          Divider(height: 1),

          Expanded(
            child: _filteredStoreList.isEmpty
                ? Center(child: Text('条件に合うお店がありません\n右下のボタンから追加してね！', textAlign: TextAlign.center))
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0), // Padding to avoid FAB overlay
                    itemCount: _filteredStoreList.length,
                    itemBuilder: (context, index) {
                      final store = _filteredStoreList[index];
                      final tags = store['tags'] as List;
                      
                      return Card(
                        margin: EdgeInsets.only(bottom: 12.0),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) {
                                return AddPage(storeToEdit: Map<String, dynamic>.from(store));
                              })
                            );
                            _loadStores();
                          },
                          title: Text(
                            '${store['prefecture']} ${store['city'] ?? ''}\n${store['storeName']}',
                          ),
                          subtitle: tags.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Wrap(
                                    spacing: 4.0,
                                    runSpacing: 4.0,
                                    children: tags.map((t) => Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.blue.shade200)
                                      ),
                                      child: Text('#${t['name']}', style: TextStyle(fontSize: 12, color: Colors.blue.shade700)),
                                    )).toList(),
                                  ),
                                )
                              : null,
                          titleTextStyle: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 22, 22, 22),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red.shade400),
                            onPressed: () => _deleteStore(store['id']),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return AddPage();
            })
          );
          _loadStores();
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.orange.shade400,
      ),
    );
  }
}
