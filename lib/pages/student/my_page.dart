// 我的页面
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'components/components.dart';

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
        const Logout()
      ],
    );
  }
}
