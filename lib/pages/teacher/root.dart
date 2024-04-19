import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../../state_notifier.dart';
import '../../functions/check_login.dart';
import 'home_page.dart';
import 'history_page.dart';
import 'my_page.dart';

class TeaApp extends StatelessWidget {
  const TeaApp({super.key});
  static String id = 'tea_app';

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
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.data == true) {
          // 用户验证成功
          return Consumer<StateNotifier>(
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
          );
        } else {
          // 用户验证失败或会话过期
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('登录会话已过期，请重新登录')),
            );
          });
          return const HomePage();
        }
      },
    );
  }
}
