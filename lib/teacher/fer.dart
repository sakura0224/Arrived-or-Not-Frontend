import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:typed_data';
import '../global_config.dart';

class FER extends StatelessWidget {
  const FER({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: const Text('课堂专注度检测'),
          ),
          body: const TabBarView(
            children: [
              RTSP(),
              Analysis(),
            ],
          ),
          bottomNavigationBar: const TabBar(tabs: [
            Tab(icon: Icon(Icons.lens_blur), text: '检测'),
            Tab(icon: Icon(Icons.analytics), text: '分析'),
          ])),
    );
  }
}

class RTSP extends StatefulWidget {
  const RTSP({super.key});

  @override
  RTSPState createState() => RTSPState();
}

class RTSPState extends State<RTSP> {
  WebSocketChannel? channel;
  Uint8List? jpegImageBytes;

  @override
  void initState() {
    super.initState();
    initializeWebSocket();
  }

  void initializeWebSocket() {
    channel = WebSocketChannel.connect(
      Uri.parse(
          'ws://${GlobalConfig.serverIpAddress}:${GlobalConfig.serverPort}/ws'),
    );

    channel?.stream.listen((message) {
      setState(() {
        jpegImageBytes = message;
      });
    });
  }

  @override
  void dispose() {
    channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: jpegImageBytes != null
            ? Image.memory(
                jpegImageBytes!,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Text('Error displaying image'));
                },
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}

class Analysis extends StatelessWidget {
  const Analysis({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('开发中'),
    );
  }
}
