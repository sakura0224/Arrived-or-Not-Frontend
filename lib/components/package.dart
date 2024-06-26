import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Package extends StatefulWidget {
  const Package({super.key});

  @override
  PackageStatus createState() => PackageStatus();
}

class PackageStatus extends State<Package> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
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
    return ListTile(
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
    );
  }
}