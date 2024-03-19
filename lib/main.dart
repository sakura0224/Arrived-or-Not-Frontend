// 导入相关的包
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'global_config.dart';
import 'state_notifier.dart';
import 'pages/home_page.dart';
import 'pages/history_page.dart';
import 'pages/my_page.dart';

// 程序入口
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfig.loadServerSettings();
  runApp(
    ChangeNotifierProvider(
      create: (context) => StateNotifier(),
      child: const MyApp(),
    ),
  );
}

// 应用程序
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '到没到',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
      ),
      home: Consumer<StateNotifier>(
        builder: (context, imageNotifier, child) {
          return ModalProgressHUD(
            inAsyncCall: imageNotifier.isLoading,
            progressIndicator: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                Material(
                  color: Colors.transparent,
                  child: Text("识别中...",
                      style: TextStyle(color: Colors.blueGrey, fontSize: 15)),
                ),
              ],
            ),
            child: DefaultTabController(
              length: 3,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('到没到'),
                ),
                body: const TabBarView(
                  children: [
                    HomePage(), // 主页页面
                    HistoryPage(), // 历史页面
                    MyPage(), // 我的页面
                  ],
                ),
                bottomNavigationBar: const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.home), text: '主页'),
                    Tab(icon: Icon(Icons.history), text: '历史'),
                    Tab(icon: Icon(Icons.person), text: '我的'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}