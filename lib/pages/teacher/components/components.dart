import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../global_config.dart';
import '../../login/screens/home_screen.dart';

class SetIP extends StatefulWidget {
  const SetIP({super.key});
  @override
  SetIPStatus createState() => SetIPStatus();
}

class SetIPStatus extends State<SetIP> {
  String _ipAddress = '';
  String _port = '';
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.settings), // 齿轮图标
      title: const Text('配置服务端地址'),
      onTap: () async {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('配置服务端地址'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    onChanged: (value) {
                      _ipAddress = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'IP地址',
                    ),
                  ),
                  TextField(
                    onChanged: (value) {
                      _port = value;
                    },
                    decoration: const InputDecoration(
                      labelText: '端口',
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('取消'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('确认'),
                  onPressed: () {
                    // 在异步操作前获取NavigatorState
                    final navigator = Navigator.of(context);
                    // 异步保存IP地址和端口
                    GlobalConfig.saveServerSettings(_ipAddress, _port)
                        .then((_) {
                      setState(() {
                        GlobalConfig.serverIpAddress = _ipAddress;
                        GlobalConfig.serverPort = _port;
                      });
                      navigator.pop(); // 使用预先获取的navigator来关闭对话框
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('配置地址成功')),
                      );
                    }).catchError((error) {
                      // 处理错误，弹出消息“出现错误，请稍后再试”，并且关闭对话框
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('出现错误，请稍后再试'),
                        ),
                      );
                      navigator.pop();
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class Logout extends StatefulWidget {
  const Logout({super.key});
  @override
  LogoutStatus createState() => LogoutStatus();
}

class LogoutStatus extends State<Logout> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
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
                    await prefs.remove('jwtToken');
                    await prefs.remove('userType');
                    if (context.mounted) {
                      // 关闭对话框并显示提示
                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已退出登录')),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()),
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
    );
  }
}

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
