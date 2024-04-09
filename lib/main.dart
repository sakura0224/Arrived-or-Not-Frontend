// 导入相关的包
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'global_config.dart';
import 'state_notifier.dart';
import 'pages/login/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/teacher/root.dart';
import 'pages/student/root.dart';


// 程序入口
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfig.loadServerSettings();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool teaLoggedIn = prefs.getBool('teaLoggedIn') ?? false;
  bool stuLoggedIn = prefs.getBool('stuLoggedIn') ?? false;
  Widget homePage;
  if (teaLoggedIn) {
    homePage = const TeaApp();
  } else if (stuLoggedIn) {
    homePage = const StuApp();
  } else {
    homePage = const LoginPage();
  }
  runApp(
    ChangeNotifierProvider(
      create: (context) => StateNotifier(),
      child: MaterialApp(
        home: homePage,
      ),
    ),
  );
}
