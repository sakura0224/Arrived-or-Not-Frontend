import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../global_config.dart';

Future<void> uploadVideo(String videoPath, BuildContext context) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    var uri = Uri.parse(
        'http://${GlobalConfig.serverIpAddress}:${GlobalConfig.serverPort}/video');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('video', videoPath));

    var response = await request.send();

    if (response.statusCode == 200) {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('视频上传成功')));
    } else {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('视频上传失败')));
    }
  } catch (e) {
    scaffoldMessenger.showSnackBar(SnackBar(content: Text('视频上传失败：$e')));
  }
}
