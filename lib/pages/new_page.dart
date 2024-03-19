// 用于显示识别结果的页面
import 'dart:io';
import 'package:flutter/material.dart';
import '../functions/add_record.dart';


class NewPage extends StatefulWidget {
  final String imagePath;
  final String text;
  final String faceNums; // 添加这个参数
  final bool shouldAddRecord; // 添加这个参数

  const NewPage(
      {super.key,
      required this.imagePath,
      required this.text,
      required this.faceNums,
      this.shouldAddRecord = false});

  @override
  NewPageState createState() => NewPageState();
}

class NewPageState extends State<NewPage> {
  @override
  void initState() {
    super.initState();
    if (widget.shouldAddRecord) {
      // 根据标志决定是否添加记录
      addRecord(widget.imagePath, widget.text, widget.faceNums);
    }
  }

  // 识别结果页面
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('识别结果'),
      ),
      body: Column(
        children: <Widget>[
          Image.file(File(widget.imagePath)),
          Text(widget.faceNums),
          Text(widget.text),
        ],
      ),
    );
  }
}