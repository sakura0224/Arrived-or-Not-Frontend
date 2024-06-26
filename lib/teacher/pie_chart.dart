// 用于展示饼图的页面

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartScreen extends StatelessWidget {
  final int totalCount;
  final int concentratedCount;
  final int absentMindedCount;

  const PieChartScreen(
      {super.key,
      required this.totalCount,
      required this.concentratedCount,
      required this.absentMindedCount});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('总人数: $totalCount'),
          Text('专注人数: $concentratedCount'),
          Text('走神人数: $absentMindedCount'),
          const SizedBox(height: 20),
          totalCount > 0
              ? SizedBox(
                  width: 200, // 明确的宽度
                  height: 200, // 明确的高度
                  child: PieChart(
                    PieChartData(
                      sections: showingSections(),
                      centerSpaceRadius: 40,
                      sectionsSpace: 0,
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return [
      PieChartSectionData(
        color: Colors.green,
        value: concentratedCount.toDouble(),
        title: '${(concentratedCount / totalCount * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Color(0xffffffff),
        ),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: absentMindedCount.toDouble(),
        title: '${(absentMindedCount / totalCount * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Color(0xffffffff),
        ),
      ),
    ];
  }
}
