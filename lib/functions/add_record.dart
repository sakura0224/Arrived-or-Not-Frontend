// 用于添加记录的函数
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';


void addRecord(String imagePath, String text, String faceNums) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> records = prefs.getStringList('records') ?? [];
  String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  int count = 1;
  for (String record in records.reversed) {
    List<String> parts = record.split('|');
    String recordDate = parts[2].split(' ')[0];
    if (recordDate == today) {
      count = int.parse(parts[3]) + 1;
      break;
    }
  }
  records.add(
      '$imagePath|$text|$now|$count|$faceNums'); // 添加新记录
  await prefs.setStringList('records', records); // 保存更新后的records列表
}