import 'package:flutter/material.dart';
import 'home_page.dart';
import 'my_page.dart';
import '../../functions/check_login.dart';
import '../login/screens/home_screen.dart';

class StuApp extends StatelessWidget {
  const StuApp({super.key});
  static String id = 'stu_app';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: validateJwt(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: () {
                      // 添加重新验证或刷新页面的逻辑
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const HomeScreen()));
                    },
                    child: const Text('返回主页'),
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.data == true) {
          return DefaultTabController(
            length: 2,
            child: Builder(
              builder: (BuildContext context) {
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('到没到'),
                  ),
                  body: const TabBarView(
                    children: [
                      CameraPage(), // 拍照页面
                      MyPage(), // 我的页面
                    ],
                  ),
                  bottomNavigationBar: const TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.camera_alt), text: '采集'),
                      Tab(icon: Icon(Icons.person), text: '我的'),
                    ],
                  ),
                );
              },
            ),
          );
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('登录会话已过期，请重新登录')),
            );
          });
          return Scaffold(body: Container()); // 返回一个空容器，避免界面异常
        }
      },
    );
  }
}
