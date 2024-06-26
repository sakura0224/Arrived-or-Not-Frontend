// 主页，包含横幅和应用区块

import 'package:flutter/material.dart';
import 'banner.dart'; // 引入横幅组件
import 'app_section.dart'; // 引入应用区块组件
import 'teacher/homeapp.dart';
import 'student/homeapp.dart';

class HomePage extends StatelessWidget {
  final String? userType;
  const HomePage({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    final classData = userType == 'teacher' ? TClassData() : SClassData();
    final eduData =
        userType == 'teacher' ? TEduData() : SEduData();
    final analysisData = userType == 'teacher' ? TAnalysisData() : NoData();
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('主页'),
      // ),
      body: Column(
        children: <Widget>[
          const BannerWidget(), // 添加横幅组件
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  AppSection(
                    title: classData.title,
                    icons: classData.icons,
                    names: classData.names,
                    pages: classData.pages,
                  ),
                  AppSection(
                    title: eduData.title,
                    icons: eduData.icons,
                    names: eduData.names,
                    pages: eduData.pages,
                  ),
                  AppSection(
                    title: analysisData.title,
                    icons: analysisData.icons,
                    names: analysisData.names,
                    pages: analysisData.pages,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
