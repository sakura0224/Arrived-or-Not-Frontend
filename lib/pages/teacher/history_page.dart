// 用于显示历史记录的页面
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'new_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  HistoryPageState createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  List<String> records = [];
  String? record;

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  void loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      records = prefs.getStringList('records') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    records.sort((a, b) {
      final partsA = a.split('|');
      final partsB = b.split('|');
      final timeA = DateTime.parse(partsA[2]);
      final timeB = DateTime.parse(partsB[2]);
      return -timeA.compareTo(timeB);
    });
    return Scaffold(
      body: records.isEmpty
          ? const Center(child: Text('没有历史记录'))
          : ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                // 分割每条记录的字符串以获取图片路径和其他信息
                final parts = records[index].split('|');
                final imagePath = parts[0];
                final name = parts.length > 1 ? parts[1] : '未知尺寸';
                final time = parts[2];
                final count = parts.length > 3 ? parts[3] : '1';
                final faceNums = parts.length > 4 ? parts[4] : '0';
                String head = DateFormat('M月d日').format(DateTime.parse(time));

                // 确保parts的长度大于等于3
                if (parts.length < 4) {
                  return Container(); // 或者一个占位符Widget
                }

                // 创建列表项
                return ListTile(
                  leading: Image.file(File(imagePath)),
                  title: Text('$head第$count次签到'),
                  subtitle: Text(time),
                  onTap: () {
                    // 点击跳转到NewPage，并传递图片路径和尺寸
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewPage(
                          imagePath: imagePath,
                          text: name,
                          faceNums: faceNums,
                          shouldAddRecord: false, // 假设NewPage接受一个标志以决定是否添加记录
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
