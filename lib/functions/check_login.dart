import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'handshake.dart';
import '../global_config.dart';

Future<bool> validateJwt() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('jwtToken');

  if (token == null) return false; // 如果本地没有token，直接返回false
  HandshakeStatus status = await sendHandshakeRequest();
  if (status == HandshakeStatus.success) {
    var response = await http.get(
      Uri.parse(
          'http://${GlobalConfig.serverIpAddress}:${GlobalConfig.serverPort}/validateToken'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      // 根据你的服务器响应逻辑，你可能需要检查响应体的内容
      return true; // Token is still valid
    } else if (response.statusCode == 403) {
      await prefs.remove('jwtToken');
      await prefs.remove('userType');
      return false; // Token is invalid
    }
  }
  await prefs.remove('jwtToken');
  await prefs.remove('userType');
  return false; // Token is invalid or request failed
}
