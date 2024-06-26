// 我的页面，调用了根目录下的components文件夹中的组件
import 'package:flutter/material.dart';
import 'components/clear_cache.dart';
import 'components/package.dart';
import 'components/logout.dart';
import 'components/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  MyPageState createState() => MyPageState();
}

class MyPageState extends State<MyPage> {
  String name = '用户';
  String number = '10000000';
  String avatar = '';

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '用户';
      number = prefs.getString('number') ?? '10000000';
      avatar = prefs.getString('avatar') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Avatar(name: name, number: number, avatar: avatar),
        Profile(name: name, number: number),
        const ClearCache(),
        const Package(),
        const Logout()
      ],
    );
  }
}
