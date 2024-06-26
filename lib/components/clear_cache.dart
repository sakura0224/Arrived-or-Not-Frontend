import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClearCache extends StatefulWidget {
  const ClearCache({super.key});

  @override
  ClearCacheStatus createState() => ClearCacheStatus();
}

class ClearCacheStatus extends State<ClearCache> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
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
                    final directory = await getApplicationDocumentsDirectory();

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
    );
  }
}
