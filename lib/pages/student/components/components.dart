import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../login/screens/home_screen.dart';

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
