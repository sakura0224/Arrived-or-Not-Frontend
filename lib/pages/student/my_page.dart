// 我的页面
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../login/login_page.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  MyPageState createState() => MyPageState();
}

class MyPageState extends State<MyPage> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('关于'),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: _packageInfo.appName,
              applicationVersion: _packageInfo.version,
              applicationIcon: Image.asset(
                'assets/icon_app.png',
                width: 50, // 设置图像的宽度为100像素
                height: 50, // 设置图像的高度为100像素
              ),
              children: const <Widget>[
                Text('上海大学大创项目'),
              ],
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: const Text('退出登录'),
          onTap: () async {
            // 显示确认对话框
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('退出登录'),
                  content: const Text('确定要退出登录吗？'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('取消'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                    TextButton(
                      onPressed: () async {
                        // 清除SharedPreferences中的记录
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('stuLoggedIn');
                        await prefs.remove('teaLoggedIn');
                        if (context.mounted) {
                          // 关闭对话框并显示提示
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('已退出登录')),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        }
                      },
                      child: const Text('确认'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
