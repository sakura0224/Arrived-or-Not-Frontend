// 上传图片的相关函数，在home_page.dart中调用uploadImage函数，该函数会调用sendHandshakeRequest函数，如果握手成功，会调用http.MultipartRequest的send方法上传图片，然后解析服务器返回的json数据，最后跳转到NewPage页面。NewPage页面会根据shouldAddRecord参数决定是否添加记录。
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../global_config.dart';
import 'package:path_provider/path_provider.dart';
import '../pages/teacher/new_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 上传图片
Future<void> uploadImage(String imagePath, BuildContext context) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('jwtToken');
  try {
    var uri = Uri.parse(
        'http://${GlobalConfig.serverIpAddress}:${GlobalConfig.serverPort}/image');
    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Authorization': 'Bearer $token', // 添加 Authorization 头
      })
      ..files.add(await http.MultipartFile.fromPath('image', imagePath));

    var response = await request.send();

    if (response.statusCode == 200) {
      response.stream.transform(utf8.decoder).listen((value) async {
        Map<String, dynamic> result = jsonDecode(value);
        // 如果服务器返回的json每一项数据都是有效的
        if (result['imageUrl'] != null) {
          var imageResponse = await http.get(Uri.parse(result['imageUrl']));
          var documentsDirectory = await getApplicationDocumentsDirectory();
          var now = DateTime.now().millisecondsSinceEpoch;
          var filePath = '${documentsDirectory.path}/image_$now.jpg';
          await File(filePath).writeAsBytes(imageResponse.bodyBytes);
          // 假设服务器返回的数据是有效的
          bool shouldAddRecord = true;
          List<String> names =
              result['name'] != null ? List<String>.from(result['name']) : [];
          String text =
              names.isNotEmpty ? '已到学生名单：${names.join('，')}。' : '识别失败';
          String faceNums = '已到学生${result['face_nums']}人。';
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewPage(
                  imagePath: filePath,
                  text: text,
                  faceNums: faceNums,
                  shouldAddRecord: shouldAddRecord,
                ),
              ),
            );
          } else {
            scaffoldMessenger
                .showSnackBar(const SnackBar(content: Text('接收失败，请不要退出应用')));
          }
        } else {
          scaffoldMessenger
              .showSnackBar(const SnackBar(content: Text('服务器返回的数据不完整')));
        }
      });
    } else {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('图片上传失败')));
    }
  } catch (e) {
    scaffoldMessenger.showSnackBar(SnackBar(content: Text('图片上传失败：$e')));
  }
}
