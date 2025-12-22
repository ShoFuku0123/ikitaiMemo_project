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
          // アプリ全体のベースカラー。ボタンの押し色や影、
          // colorScheme.primary などのデフォルト値に影響します。
          seedColor: const Color(0xFFD35400), 
          // カードの背景やダイアログ、ドロップダウンなどの背景色に影響します。
          surface: const Color(0xFFFDF5E6),   
        ),
        // 画面全体の背景色（Scaffold のデフォルト背景色）
        scaffoldBackgroundColor: const Color(0xFFFDF5E6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, // AppBar 自体は透明（背景画像を見せるため）
          centerTitle: true,
          toolbarHeight: 75,
        ),
        // アプリ内の ElevatedButton 全体の共通デザイン
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            // ボタンの背景色（現在は seedColor と同じオレンジ）
            backgroundColor: const Color(0xFFD35400),
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