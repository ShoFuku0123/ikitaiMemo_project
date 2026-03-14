import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'database_helper.dart';

class AddPage extends StatefulWidget {
  final Map<String, dynamic>? storeToEdit;

  const AddPage({Key? key, this.storeToEdit}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final formKey = GlobalKey<FormState>();

  String prefecture = '';
  String city = '';
  String storeName = '';

  Map<String, List<Map<String, dynamic>>> citiesData = {};
  List<Map<String, dynamic>> currentCities = [];

  List<Map<String, dynamic>> availableTags = [];
  Set<int> selectedTags = {};

  final TextEditingController _prefController = TextEditingController();
  final FocusNode _prefFocus = FocusNode();
  
  final TextEditingController _cityController = TextEditingController();
  final FocusNode _cityFocus = FocusNode();

  final TextEditingController _newTagController = TextEditingController();

  static const List<Map<String, String>> prefecturesData = [
    {"name": "北海道", "kana": "ほっかいどう"},
    {"name": "青森県", "kana": "あおもりけん"},
    {"name": "岩手県", "kana": "いわてけん"},
    {"name": "宮城県", "kana": "みやぎけん"},
    {"name": "秋田県", "kana": "あきたけん"},
    {"name": "山形県", "kana": "やまがたけん"},
    {"name": "福島県", "kana": "ふくしまけん"},
    {"name": "茨城県", "kana": "いばらきけん"},
    {"name": "栃木県", "kana": "とちぎけん"},
    {"name": "群馬県", "kana": "ぐんまけん"},
    {"name": "埼玉県", "kana": "さいたまけん"},
    {"name": "千葉県", "kana": "ちばけん"},
    {"name": "東京都", "kana": "とうきょうと"},
    {"name": "神奈川県", "kana": "かながわけん"},
    {"name": "新潟県", "kana": "にいがたけん"},
    {"name": "富山県", "kana": "とやまけん"},
    {"name": "石川県", "kana": "いしかわけん"},
    {"name": "福井県", "kana": "ふくいけん"},
    {"name": "山梨県", "kana": "やまなしけん"},
    {"name": "長野県", "kana": "ながのけん"},
    {"name": "岐阜県", "kana": "ぎふけん"},
    {"name": "静岡県", "kana": "しずおかけん"},
    {"name": "愛知県", "kana": "あいちけん"},
    {"name": "三重県", "kana": "みえけん"},
    {"name": "滋賀県", "kana": "しがけん"},
    {"name": "京都府", "kana": "きょうとふ"},
    {"name": "大阪府", "kana": "おおさかふ"},
    {"name": "兵庫県", "kana": "ひょうごけん"},
    {"name": "奈良県", "kana": "ならけん"},
    {"name": "和歌山県", "kana": "わかやまけん"},
    {"name": "鳥取県", "kana": "とっとりけん"},
    {"name": "島根県", "kana": "しまねけん"},
    {"name": "岡山県", "kana": "おかやまけん"},
    {"name": "広島県", "kana": "ひろしまけん"},
    {"name": "山口県", "kana": "やまぐちけん"},
    {"name": "徳島県", "kana": "とくしまけん"},
    {"name": "香川県", "kana": "かがわけん"},
    {"name": "愛媛県", "kana": "えひめけん"},
    {"name": "高知県", "kana": "こうちけん"},
    {"name": "福岡県", "kana": "ふくおかけん"},
    {"name": "佐賀県", "kana": "さがけん"},
    {"name": "長崎県", "kana": "ながさきけん"},
    {"name": "熊本県", "kana": "くまもとけん"},
    {"name": "大分県", "kana": "おおいたけん"},
    {"name": "宮崎県", "kana": "みやざきけん"},
    {"name": "鹿児島県", "kana": "かごしまけん"},
    {"name": "沖縄県", "kana": "おきなわけん"},
  ];

  @override
  void initState() {
    super.initState();
    _loadData().then((_) {
      if (widget.storeToEdit != null) {
        final store = widget.storeToEdit!;
        setState(() {
          prefecture = store['prefecture'] ?? '';
          city = store['city'] ?? '';
          storeName = store['storeName'] ?? '';
          
          if (prefecture.isNotEmpty) {
            currentCities = citiesData[prefecture] ?? [];
            _prefController.text = prefecture;
          }
          if (city.isNotEmpty) {
            _cityController.text = city;
          }
          if (store['tags'] != null) {
            final tags = store['tags'] as List;
            selectedTags = tags.map((t) => t['id'] as int).toSet();
          }
        });
      }
    });
  }

  Future<void> _loadData() async {
    final String response = await rootBundle.loadString('assets/cities.json');
    final Map<String, dynamic> data = json.decode(response);
    
    final db = await DatabaseHelper.instance.database;
    final tags = await db.query('tags');
    
    setState(() {
      citiesData = data.map((key, value) => MapEntry(
          key, List<Map<String, dynamic>>.from(value)));
      availableTags = List<Map<String, dynamic>>.from(tags);
    });
  }

  @override
  void dispose() {
    _prefController.dispose();
    _cityController.dispose();
    _prefFocus.dispose();
    _cityFocus.dispose();
    _newTagController.dispose();
    super.dispose();
  }

  Future<void> _addNewTag(String tagName) async {
    final trimmed = tagName.trim();
    if (trimmed.isEmpty) return;
    
    final exists = availableTags.any((t) => t['name'] == trimmed);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('同名のタグが既に存在します')));
      return;
    }

    final db = await DatabaseHelper.instance.database;
    try {
      int id = await db.insert('tags', {'name': trimmed});
      setState(() {
        availableTags.add({'id': id, 'name': trimmed});
        selectedTags.add(id);
        _newTagController.clear();
      });
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('タグの追加に失敗しました')));
    }
  }

  Future<void> _deleteTag(int tagId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('tags', where: 'id = ?', whereArgs: [tagId]);
    setState(() {
      availableTags.removeWhere((t) => t['id'] == tagId);
      selectedTags.remove(tagId);
    });
  }

  void _showAddTagDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('新しいタグを作成'),
          content: TextField(
            controller: _newTagController,
            decoration: InputDecoration(hintText: '例】ラーメン'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () => _addNewTag(_newTagController.text),
              child: Text('追加'),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.storeToEdit != null;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 75,
        flexibleSpace: Image.asset(
          'images/AppBar.jpg',
          fit: BoxFit.fitWidth,
        ),
        title: Text(
          isEditing ? '編集する' : '行きたいメモ',
          style: GoogleFonts.yuseiMagic(
            color: Color.fromARGB(255, 0, 0, 0),
            fontSize: 52,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Color.fromARGB(255, 253, 220, 195),
      body: SingleChildScrollView(
        child: Container(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // 都道府県
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 16.0),
                  child: RawAutocomplete<Map<String, String>>(
                    textEditingController: _prefController,
                    focusNode: _prefFocus,
                    displayStringForOption: (option) => option['name']!,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      final text = textEditingValue.text.trim();
                      if (text.isEmpty) return prefecturesData;
                      return prefecturesData.where((option) {
                        return option['name']!.contains(text) || option['kana']!.contains(text);
                      });
                    },
                    onSelected: (Map<String, String> selection) {
                      setState(() {
                        prefecture = selection['name']!;
                        currentCities = citiesData[selection['name']] ?? [];
                        city = '';
                        _cityController.text = ''; // Reset city selection
                      });
                    },
                    fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        style: const TextStyle(fontSize: 20),
                        decoration: const InputDecoration(
                          labelText: '都道府県',
                          labelStyle: TextStyle(fontSize: 20, color: Color.fromARGB(140, 0, 0, 0)),
                          hintText: 'タップして都道府県を選択',
                          hintStyle: TextStyle(fontSize: 20, color: Color.fromARGB(140, 0, 0, 0)),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(width: 2.0, color: Color.fromARGB(255, 91, 160, 210)),
                          ),
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        onTap: () {
                          // Force Autocomplete options to show up even if empty
                          if (controller.text.isEmpty) {
                            controller.text = ' ';
                            controller.text = '';
                          }
                        },
                        onChanged: (value) {
                          prefecture = value;
                          if (citiesData.containsKey(value)) {
                            setState(() {
                              currentCities = citiesData[value] ?? [];
                            });
                          } else {
                            setState(() {
                              currentCities = [];
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) return '入力してください';
                          if (!prefecturesData.any((p) => p['name'] == value)) return 'リストから正しい都道府県を選択してください';
                          return null;
                        },
                        onSaved: (value) {
                          prefecture = value ?? '';
                        },
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4.0,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 200, maxWidth: 350),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final option = options.elementAt(index);
                                return InkWell(
                                  onTap: () => onSelected(option),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(option['name']!, style: const TextStyle(fontSize: 18)),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // 市区町村
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                  child: RawAutocomplete<Map<String, dynamic>>(
                    textEditingController: _cityController,
                    focusNode: _cityFocus,
                    displayStringForOption: (option) => option['name'] as String,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (currentCities.isEmpty) return const Iterable<Map<String, dynamic>>.empty();
                      final text = textEditingValue.text.trim();
                      if (text.isEmpty) return currentCities;
                      return currentCities.where((option) {
                        final name = option['name'] as String;
                        final kana = option['kana'] as String;
                        return name.contains(text) || kana.contains(text);
                      });
                    },
                    onSelected: (Map<String, dynamic> selection) {
                      setState(() {
                        city = selection['name'] as String;
                      });
                    },
                    fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        style: const TextStyle(fontSize: 20),
                        enabled: prefecture.isNotEmpty && currentCities.isNotEmpty,
                        decoration: InputDecoration(
                          labelText: '市区町村',
                          labelStyle: TextStyle(fontSize: 20, color: Color.fromARGB(140, 0, 0, 0)),
                          hintText: prefecture.isEmpty ? '先に都道府県を選択してください' : 'タップして市区町村を選択',
                          hintStyle: TextStyle(fontSize: 20, color: Color.fromARGB(140, 0, 0, 0)),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(width: 2.0, color: Color.fromARGB(255, 91, 160, 210)),
                          ),
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        onTap: () {
                          if (controller.text.isEmpty && currentCities.isNotEmpty) {
                            controller.text = ' ';
                            controller.text = '';
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) return '入力してください';
                          if (!currentCities.any((c) => c['name'] == value)) return 'リストから正しい市区町村を選択してください';
                          return null;
                        },
                        onSaved: (value) {
                          city = value ?? '';
                        },
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4.0,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 200, maxWidth: 350),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final option = options.elementAt(index);
                                return InkWell(
                                  onTap: () => onSelected(option),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(option['name'] as String, style: const TextStyle(fontSize: 18)),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 店名
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    initialValue: isEditing ? widget.storeToEdit!['storeName'] : null,
                    style: TextStyle(fontSize: 20),
                    decoration: const InputDecoration(
                      labelText: '施設名 or キーワード',
                      labelStyle: TextStyle(fontSize: 20, color: Color.fromARGB(140, 0, 0, 0)),
                      hintText: '例】 喫茶〇〇 本店',
                      hintStyle: TextStyle(fontSize: 20, color: Color.fromARGB(140, 0, 0, 0)),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(width: 2.0, color: Color.fromARGB(255, 91, 160, 210)),
                      )
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return '入力してください';
                      return null;
                    },
                    onSaved: (value) {
                      storeName = value ?? '';
                    },
                  ),
                ),

                // タグ選択
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('タグ（複数選択可）', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                          ElevatedButton.icon(
                            onPressed: _showAddTagDialog,
                            icon: Icon(Icons.add, size: 18),
                            label: Text('追加'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue,
                              side: BorderSide(color: Colors.blue.shade200),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: availableTags.map((tag) {
                          final isSelected = selectedTags.contains(tag['id']);
                          return InputChip(
                            label: Text(tag['name'] as String, style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87
                            )),
                            selected: isSelected,
                            selectedColor: Colors.blue,
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  selectedTags.add(tag['id'] as int);
                                } else {
                                  selectedTags.remove(tag['id'] as int);
                                }
                              });
                            },
                            onDeleted: () => _deleteTag(tag['id'] as int),
                            deleteIconColor: isSelected ? Colors.white70 : Colors.black54,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24.0),
                // 追加/更新ボタン
                Container(
                  padding: const EdgeInsets.fromLTRB(64.0, 16.0, 64.0, 8.0),
                  width: double.infinity,
                  height: 90,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState?.save();
                        
                        if (isEditing) {
                          await DatabaseHelper.instance.updateStoreWithTags(
                            widget.storeToEdit!['id'] as int,
                            prefecture,
                            city,
                            storeName,
                            selectedTags.toList()
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              content: Text(
                                '〜〜更新完了〜〜',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          );
                          Navigator.of(context).pop();
                        } else {
                          await DatabaseHelper.instance.insertStoreWithTags(
                            prefecture,
                            city,
                            storeName,
                            selectedTags.toList()
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              content: Text(
                                '〜〜追加完了〜〜',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          );
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const AddPage())
                          );
                        }
                      }
                    },
                    child: Text(
                      isEditing ? '更新 !!!' : '追加 !!!',
                      style: TextStyle(fontSize: 25, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 255, 179, 92)),
                  ),
                ),
                // ListPageに戻るボタン
                Container(
                  padding: const EdgeInsets.fromLTRB(64.0, 8.0, 64.0, 32.0),
                  width: double.infinity,
                  height: 90,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'リストにもどる',
                      style: TextStyle(fontSize: 17, color: Colors.blue),
                    ),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 255, 255, 255)),
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