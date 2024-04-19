import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import '../../functions/upload_video.dart';
import '../../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late CameraController controller;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    controller = CameraController(
      cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      ),
      ResolutionPreset.medium,
    );
    await controller.initialize();
    setState(() {}); // Ensure UI is updated after initialization
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> startVideoRecording() async {
    if (!controller.value.isInitialized || isRecording) {
      return;
    }
    try {
      await controller.startVideoRecording();
      setState(() {
        isRecording = true;
      });

      // Automatically stop recording after 5 seconds
      await Future.delayed(const Duration(seconds: 5));
      await stopVideoRecording();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('采集视频失败: $e')),
        );
      }
    }
  }

  Future<void> stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return;
    }

    try {
      XFile videoFile = await controller.stopVideoRecording();
      setState(() {
        isRecording = false;
      });
      if (mounted) {
        await uploadVideo(videoFile.path, context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('停止采集失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(title: const Text('采集面部信息时请轻微晃动头部')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: CameraPreview(controller), // Camera preview is shown here
          ),
          ElevatedButton(
            onPressed: isRecording ? null : startVideoRecording,
            child: Text(isRecording ? '采集中...' : '开始采集'),
          )
        ],
      ),
    );
  }
}
