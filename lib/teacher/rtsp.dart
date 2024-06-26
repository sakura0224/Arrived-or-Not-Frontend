// 用于展示实时视频流和专注度检测结果的页面

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import '../global_config.dart';
import 'pie_chart.dart';
import 'single_tab.dart';

class RtspScreen extends StatefulWidget {
  const RtspScreen({super.key});

  @override
  RtspScreenState createState() => RtspScreenState();
}

class RtspScreenState extends State<RtspScreen>
    with SingleTickerProviderStateMixin {
  late WebSocketChannel channel;
  int totalCount = 0;
  int concentratedCount = 0;
  int absentMindedCount = 0;
  bool isWebSocketConnected = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    channel.sink.close();
    _tabController.dispose();
    super.dispose();
  }

  void _toggleWebSocketConnection() {
    if (isWebSocketConnected) {
      channel.sink.close(1000);
      setState(() {
        isWebSocketConnected = false;
      });
    } else {
      channel = WebSocketChannel.connect(Uri.parse(
          'ws://${GlobalConfig.serverIpAddress}:${GlobalConfig.serverPort}/ws'));

      setState(() {
        isWebSocketConnected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('课堂专注度检测'),
        actions: [
          IconButton(
            icon: Icon(isWebSocketConnected ? Icons.pause : Icons.play_arrow),
            onPressed: _toggleWebSocketConnection,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '检测'),
            Tab(text: '分析'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          // CameraStreamPage(jpegImageBytes: jpegImageBytes),
          const SingleTab(),
          isWebSocketConnected
              ? StreamBuilder(
                  stream: channel.stream.asBroadcastStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final data = jsonDecode(snapshot.data);
                      totalCount = int.parse(data['total_count']);
                      concentratedCount = int.parse(data['concentrated_count']);
                      absentMindedCount =
                          int.parse(data['absent_minded_count']);
                    }
                    return PieChartScreen(
                      totalCount: totalCount,
                      concentratedCount: concentratedCount,
                      absentMindedCount: absentMindedCount,
                    );
                  },
                )
              : const Center(child: Text('WebSocket未连接')),
        ],
      ),
    );
  }
}
