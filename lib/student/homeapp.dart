// 学生端主页的功能模块

import 'package:flutter/material.dart';
import '../app_section.dart';
import '../app_page.dart';
import 'camera_page.dart';

class SClassData extends AppData {
  @override
  final String title = '📖  班级一览';

  @override
  final List<IconData> icons = [
    Icons.group_add,
    Icons.group,
  ];

  @override
  final List<String> names = [
    '加入班级',
    '成员查看',
  ];

  @override
  final List<Widget> pages = [
    const AppPage(title: '加入班级'),
    const AppPage(title: '成员查看'),
  ];
}

class SEduData extends AppData{
  @override
  final String title = '🏫  课堂学习';

  @override
  final List<IconData> icons = [
    Icons.filter_center_focus,
  ];

  @override
  final List<String> names = [
    '录入人脸',
  ];

  @override
  final List<Widget> pages = [
    const CameraPage(),
  ];
}