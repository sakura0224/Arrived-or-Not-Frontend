import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../global_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> uploadVideo(String videoPath, BuildContext context) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('jwtToken');
  try {
    var uri = Uri.parse(
        'http://${GlobalConfig.serverIpAddress}:${GlobalConfig.serverPort}/video');
    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'content_type': 'video/mp4', // 设置 Content-Type 请求头
        'Authorization': 'Bearer $token' // 添加 Authorization 头
      })
      ..files.add(await http.MultipartFile.fromPath('file', videoPath));

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
