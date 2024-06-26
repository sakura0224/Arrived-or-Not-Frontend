// 持久化储存服务器地址和端口号

import 'package:shared_preferences/shared_preferences.dart';

class GlobalConfig {
  static String serverIpAddress = '192.168.1.6';
  static String serverPort = '8000';

  static Future<void> saveServerSettings(String ipAddress, String port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('serverIpAddress', ipAddress);
    await prefs.setString('serverPort', port);
    serverIpAddress = ipAddress;
    serverPort = port;
  }

  static Future<void> loadServerSettings() async {
    final prefs = await SharedPreferences.getInstance();
    serverIpAddress = prefs.getString('serverIpAddress') ?? '192.168.1.6';
    serverPort = prefs.getString('serverPort') ?? '8000';
  }
}
