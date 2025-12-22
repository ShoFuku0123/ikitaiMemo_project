import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'list_page.dart';
import 'database_helper.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          // アプリ全体のベースカラー。1番のソフトオレンジ。
          seedColor: const Color(0xFFFFB37C), 
          // カードの背景やダイアログ、ドロップダウンなどの背景色。1番のクリーム色。
          surface: const Color(0xFFFDF5E6), 
          // ボタンの背景色。1番のコーラルレッド。
          primary: const Color(0xFFFF7F5C), 
        ),
        // 画面全体の背景色。1番のクリーム色。
        scaffoldBackgroundColor: const Color(0xFFFDF5E6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, // AppBar 自体は透明（背景画像を見せるため）
          centerTitle: true,
          toolbarHeight: 75,
        ),
        // アプリ内の ElevatedButton 全体の共通デザイン
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            // ボタンの背景色。1番のコーラルレッド。
            backgroundColor: const Color(0xFFFF7F5C),
            // ボタン上の文字やアイコンの色
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: ListPage(),
    );
  }
}