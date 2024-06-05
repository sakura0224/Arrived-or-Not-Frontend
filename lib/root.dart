import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'state_notifier.dart';
import 'functions/check_login.dart';
import 'home_page.dart';
import 'my_page.dart';
import 'login/screens/home_screen.dart';

class Root extends StatelessWidget {
  final String? userType;
  const Root({super.key, required this.userType});
  static String id = 'root';

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
          // 用户验证成功
          return Consumer<StateNotifier>(
            builder: (context, imageNotifier, child) {
              return ModalProgressHUD(
                inAsyncCall: imageNotifier.isLoading,
                child: DefaultTabController(
                  length: 2,
                  child: Scaffold(
                    appBar: AppBar(
                      title: const Text('到没到'),
                    ),
                    body: TabBarView(
                      children: [
                        HomePage(
                          userType: userType,
                        ), // 主页页面
                        const MyPage(), // 我的页面
                      ],
                    ),
                    bottomNavigationBar: const TabBar(
                      tabs: [
                        Tab(icon: Icon(Icons.home), text: '主页'),
                        Tab(icon: Icon(Icons.person), text: '我的'),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          // 用户验证失败或会话过期
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const HomeScreen())); // 重定向到登录页面
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('登录会话已过期，请重新登录')),
            );
          });
          return Scaffold(body: Container()); // 返回一个空的容器以避免界面异常
        }
      },
    );
  }
}
