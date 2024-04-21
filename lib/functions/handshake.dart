import 'package:http/http.dart' as http;
import '../global_config.dart';

// 定义一个枚举来表示不同的握手结果
enum HandshakeStatus { success, noResponse, error }

Future<HandshakeStatus> sendHandshakeRequest() async {
  try {
    var handshakeUri = Uri.parse(
        'http://${GlobalConfig.serverIpAddress}:${GlobalConfig.serverPort}/handshake');
    var response = await http
        .get(handshakeUri)
        .timeout(const Duration(seconds: 2), onTimeout: () {
      return http.Response('timeout', 408);
    });

    if (response.statusCode == 200 && response.body == 'handshake_ack') {
      return HandshakeStatus.success; // 握手成功
    } else if (response.statusCode == 408) {
      return HandshakeStatus.noResponse; // 无响应
    }
  } catch (e) {
    return HandshakeStatus.error; // 发生错误
  }
  throw Exception('Unexpected error occurred');
}


