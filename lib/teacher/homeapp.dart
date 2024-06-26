// 教师端主页的功能模块

import 'package:flutter/material.dart';
import '../app_section.dart';
import '../app_page.dart';
import 'recognize.dart';
import 'history_page.dart';
import '../student/camera_page.dart';
import 'rtsp.dart';

class TClassData extends AppData{
  @override
  final String title = '📖  班级管理';

  @override
  final List<IconData> icons = [
    Icons.class_,
    Icons.group,
    Icons.cancel,
  ];

  @override
  final List<String> names = [
    '创建班级',
    '成员管理',
    '结束课程',
  ];

  @override
  final List<Widget> pages = [
    const AppPage(title: '创建班级'),
    const AppPage(title: '成员管理'),
    const AppPage(title: '结束课程'),
  ];
}

class TEduData extends AppData{
  @override
  final String title = '🏫  课堂教学';

  @override
  final List<IconData> icons = [
    Icons.filter_center_focus,
    Icons.check_circle,
    Icons.history,
    Icons.face
  ];

  @override
  final List<String> names = [
    '录入人脸',
    '考勤签到',
    '签到历史',
    '专注检测'
  ];

  @override
  final List<Widget> pages = [
    const CameraPage(),
    const Recognize(),
    const HistoryPage(),
    const RtspScreen()
  ];
}

class TAnalysisData extends AppData{
  @override
  final String title = '💯  数据分析';

  @override
  final List<IconData> icons = [
    Icons.assignment,
    Icons.assessment,
  ];

  @override
  final List<String> names = [
    '考勤分析',
    '教学评估',
  ];

  @override
  final List<Widget> pages = [
    const AppPage(title: '考勤分析'),
    const AppPage(title: '教学评估'),
  ];
}