import 'package:flutter/material.dart';
import '../global_config.dart';

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