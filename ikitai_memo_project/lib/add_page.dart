import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_helper.dart';
import 'list_page.dart';

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
      // backgroundColor はテーマから自動適用
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
                      formKey.currentState?.reset();
                    }
                  },
                  child: const Text('追加 !!!'),
                  // style はテーマの elevatedButtonTheme から適用されるため削除
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
                    Navigator.pop(context);
                  },
                  child: Text(
                    'リストにもどる',
                    style: TextStyle(
                      fontSize: 17,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}