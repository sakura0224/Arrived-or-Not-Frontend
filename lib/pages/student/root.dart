import 'package:flutter/material.dart';
import 'home_page.dart';
import 'my_page.dart';

class StuApp extends StatelessWidget {
  const StuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: '到没到',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
          ),
        ),
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('到没到'),
            ),
            body: const TabBarView(
              children: [
                HomePage(), // 拍照页面
                MyPage(), // 我的页面
              ],
            ),
            bottomNavigationBar: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.camera_alt), text: '采集'),
                Tab(icon: Icon(Icons.person), text: '我的'),
              ],
            ),
          ),
        ));
  }
}
