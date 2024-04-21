// 我的页面
import 'package:flutter/material.dart';
import 'components/components.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  MyPageState createState() => MyPageState();
}

class MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const <Widget>[
        Package(),
        Logout()
      ],
    );
  }
}
