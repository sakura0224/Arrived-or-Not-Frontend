// 我的页面
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../global_config.dart';
import '../login/login_page.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  MyPageState createState() => MyPageState();
}

class MyPageState extends State<MyPage> {
  String _ipAddress = '';
  String _port = '';
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
        InkWell(
          onTap: () {
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
          child: const ListTile(
            leading: Icon(Icons.settings), // 齿轮图标
            title: Text('配置服务端地址'),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.cleaning_services),
          title: const Text('清除缓存'),
          onTap: () async {
            // 显示确认对话框
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('清除缓存'),
                  content: const Text('确定要清除所有历史记录和缓存吗？'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('取消'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('确认'),
                      onPressed: () async {
                        // 清除SharedPreferences中的记录
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('records');

                        // 获取应用文档目录
                        final directory =
                            await getApplicationDocumentsDirectory();

                        // 删除目录中的所有文件
                        final files = directory.listSync();
                        for (var file in files) {
                          try {
                            if (file is File) {
                              await file.delete();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('删除文件时出现错误'),
                                ),
                              );
                            }
                          }
                        }
                        if (context.mounted) {
                          // 关闭对话框并显示提示
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('已清除所有缓存')),
                          );
                        }
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
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
