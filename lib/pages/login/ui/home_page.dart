import 'package:flutter/material.dart';
import '../model/user.dart';
import 'user_provider.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    /**
     * 根据是否有用户登录信息进入登录注册页面或者主页
        利用inheritedWidget，可以读取到父控件分享的数据
     */
    UserProvider? userContainer = UserContainer.of(context);
    User? user = userContainer?.user;
    if (user == null) {
      return const LoginPage();
    } else {
      return Scaffold(
        body: Center(
          child: Text("用户已登录\n用户名:${user.username}\n密码：${user.password}"),
        ),
      );
    }
  }
}