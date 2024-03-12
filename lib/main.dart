// 导入相关的包
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'global_config.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:path_provider/path_provider.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

// 程序入口
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfig.loadServerSettings();
  runApp(
    ChangeNotifierProvider(
      create: (context) => StateNotifier(),
      child: const MyApp(),
    ),
  );
}

// 应用程序
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '到没到',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
        ),
      ),
      home: Consumer<StateNotifier>(
        builder: (context, imageNotifier, child) {
          return ModalProgressHUD(
            inAsyncCall: imageNotifier.isLoading,
            progressIndicator: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                Material(
                  color: Colors.transparent,
                  child: Text("识别中...",
                      style: TextStyle(color: Colors.blueGrey, fontSize: 15)),
                ),
              ],
            ),
            child: DefaultTabController(
              length: 3,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('到没到'),
                ),
                body: const TabBarView(
                  children: [
                    CameraPage(), // 拍照页面
                    HistoryPage(), // 历史页面
                    MyPage(), // 我的页面
                  ],
                ),
                bottomNavigationBar: const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.camera_alt), text: '识别'),
                    Tab(icon: Icon(Icons.history), text: '历史'),
                    Tab(icon: Icon(Icons.person), text: '我的'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// 用于传递图片的Provider
class StateNotifier extends ChangeNotifier {
  XFile? _image; // image_picker返回的图片
  bool _isLoading = false; // 是否正在加载

  XFile? get image => _image;
  bool get isLoading => _isLoading;

  void setImage(XFile image) {
    // 设置图片
    _image = image;
    notifyListeners();
  }

  set isLoading(bool isLoading) {
    // 设置加载状态
    _isLoading = isLoading;
    notifyListeners();
  }
}

// 拍照页面
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  Future<void> getImage(StateNotifier imageNotifier) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      imageNotifier.setImage(image);
    }
  }

// 上传图片
  Future<void> uploadImage(String imagePath, BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      var uri = Uri.parse(
          'http://${GlobalConfig.serverIpAddress}:${GlobalConfig.serverPort}/upload');
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('image', imagePath));

      var response = await request.send();

      if (response.statusCode == 200) {
        response.stream.transform(utf8.decoder).listen((value) async {
          Map<String, dynamic> result = jsonDecode(value);
          if (result['imageUrl'] != null) {
            var imageResponse = await http.get(Uri.parse(result['imageUrl']));
            var documentsDirectory = await getApplicationDocumentsDirectory();
            var now = DateTime.now().millisecondsSinceEpoch;
            var filePath = '${documentsDirectory.path}/image_$now.jpg';
            await File(filePath).writeAsBytes(imageResponse.bodyBytes);
            // 假设服务器返回的数据是有效的
            bool shouldAddRecord = result['imageUrl'] != null;
            List<String> names =
            result['size'] != null ? List<String>.from(result['size']) : [];
            String text = names.isNotEmpty
                ? '${names.join('，')}等同学已出席'
                : '识别失败';
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewPage(
                    imagePath: filePath,
                    text: text,
                    shouldAddRecord: shouldAddRecord,
                  ),
                ),
              );
              setState(() {
                Provider.of<StateNotifier>(context, listen: false).isLoading =
                    false; // 数据已返回，停止加载
              });
            } else {
              scaffoldMessenger
                  .showSnackBar(const SnackBar(content: Text('接收失败，请不要退出应用')));
            }
          } else {
            scaffoldMessenger
                .showSnackBar(const SnackBar(content: Text('服务器返回的数据不完整')));
            setState(() {
              Provider.of<StateNotifier>(context, listen: false).isLoading =
                  false; // 停止加载
            });
          }
        });
      } else {
        scaffoldMessenger.showSnackBar(const SnackBar(content: Text('图片上传失败')));
        setState(() {
          Provider.of<StateNotifier>(context, listen: false).isLoading =
              false; // 停止加载
        });
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('图片上传失败：$e')));
      setState(() {
        Provider.of<StateNotifier>(context, listen: false).isLoading =
            false; // 停止加载
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageNotifier = Provider.of<StateNotifier>(context, listen: false);

    return Scaffold(
      body: Consumer<StateNotifier>(
        builder: (context, imageNotifier, child) {
          return imageNotifier.image == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '使用前请先于“我的”——“配置服务端地址”中完成配置',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Image.file(File(imageNotifier.image!.path));
        },
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.camera),
            label: '拍照',
            onTap: () => getImage(imageNotifier),
          ),
          SpeedDialChild(
            child: const Icon(Icons.folder),
            label: '相册',
            onTap: () async {
              final pickedFile =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                // 选择照片后的代码
                imageNotifier.setImage(pickedFile);
              }
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.cloud_upload),
            label: '上传',
            onTap: () async {
              setState(() {
                Provider.of<StateNotifier>(context, listen: false).isLoading =
                    true; // 开始加载
              });
              if (imageNotifier.image == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请先拍摄照片')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('正在上传图片...请不要退出应用')),
                );
                await uploadImage(imageNotifier.image!.path, context);
              }
            },
          ),
        ],
      ),
    );
  }
}

// 识别弹出的页面
class NewPage extends StatefulWidget {
  final String imagePath;
  final String text;
  final bool shouldAddRecord; // 添加这个参数

  const NewPage(
      {super.key,
      required this.imagePath,
      required this.text,
      this.shouldAddRecord = false});

  @override
  NewPageState createState() => NewPageState();
}

class NewPageState extends State<NewPage> {
  @override
  void initState() {
    super.initState();
    if (widget.shouldAddRecord) {
      // 根据标志决定是否添加记录
      addRecord();
    }
  }

  void addRecord() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> records = prefs.getStringList('records') ?? [];
    String now = DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now());
    String today = DateFormat('yyyy/MM/dd').format(DateTime.now());

    int count = 1;
    for (String record in records.reversed) {
      List<String> parts = record.split('|');
      String recordDate = parts[2].split(' ')[0];
      if (recordDate == today) {
        count = int.parse(parts[3]) + 1;
        break;
      }
    }

    records.add('${widget.imagePath}|${widget.text}|$now|$count'); // 添加新记录
    await prefs.setStringList('records', records); // 保存更新后的records列表
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('识别结果'),
      ),
      body: Column(
        children: <Widget>[
          Image.file(File(widget.imagePath)),
          Text(widget.text),
        ],
      ),
    );
  }
}

// 历史页面
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  HistoryPageState createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  List<String> records = [];
  String? record;

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  void loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      records = prefs.getStringList('records') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: records.isEmpty
          ? const Center(child: Text('没有历史记录'))
          : ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                // 分割每条记录的字符串以获取图片路径和其他信息
                final parts = records[index].split('|');
                final imagePath = parts[0];
                final size = parts.length > 1 ? parts[1] : '未知尺寸';
                final time = parts[2];
                final count = parts.length > 3 ? parts[3] : '1';
                String head = DateFormat('M月d日').format(DateTime.now());

                // 确保parts的长度大于等于3
                if (parts.length < 4) {
                  return Container(); // 或者一个占位符Widget
                }

                // 创建列表项
                return ListTile(
                  leading: Image.file(File(imagePath)),
                  title: Text('$head第$count次签到'),
                  subtitle: Text(time),
                  onTap: () {
                    // 点击跳转到NewPage，并传递图片路径和尺寸
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewPage(
                          imagePath: imagePath,
                          text: size,
                          shouldAddRecord: false, // 假设NewPage接受一个标志以决定是否添加记录
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

// 我的页面
class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  MyPageState createState() => MyPageState();
}

class MyPageState extends State<MyPage> {
  String _ipAddress = '';
  String _port = '';

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('配置服务端地址'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        onChanged: (value) {
                          _ipAddress = value;
                        },
                        decoration: const InputDecoration(
                          labelText: 'IP地址',
                        ),
                      ),
                      TextField(
                        onChanged: (value) {
                          _port = value;
                        },
                        decoration: const InputDecoration(
                          labelText: '端口',
                        ),
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('取消'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('确认'),
                      onPressed: () {
                        // 在异步操作前获取NavigatorState
                        final navigator = Navigator.of(context);
                        // 异步保存IP地址和端口
                        GlobalConfig.saveServerSettings(_ipAddress, _port)
                            .then((_) {
                          setState(() {
                            GlobalConfig.serverIpAddress = _ipAddress;
                            GlobalConfig.serverPort = _port;
                          });
                          navigator.pop(); // 使用预先获取的navigator来关闭对话框
                        }).catchError((error) {
                          // 处理错误，弹出消息“出现错误，请稍后再试”，并且关闭对话框
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('出现错误，请稍后再试'),
                            ),
                          );
                          navigator.pop();
                        });
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: const ListTile(
            leading: Icon(Icons.settings), // 齿轮图标
            title: Text('配置服务端地址'),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.cleaning_services),
          title: const Text('清除缓存'),
          onTap: () async {
            // 显示确认对话框
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('清除缓存'),
                  content: const Text('确定要清除所有历史记录和缓存吗？'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('取消'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('确认'),
                      onPressed: () async {
                        // 清除SharedPreferences中的记录
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('records');

                        // 获取应用文档目录
                        final directory =
                            await getApplicationDocumentsDirectory();

                        // 删除目录中的所有文件
                        final files = directory.listSync();
                        for (var file in files) {
                          try {
                            if (file is File) {
                              await file.delete();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('删除文件时出现错误'),
                                ),
                              );
                            }
                          }
                        }
                        if (context.mounted) {
                          // 关闭对话框并显示提示
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('已清除所有缓存')),
                          );
                        }
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('关于'),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: '到没到',
              applicationVersion: '1.2.0',
              applicationIcon: const Icon(Icons.center_focus_strong, size: 50),
              children: const <Widget>[
                Text('上海大学大创项目'),
              ],
            );
          },
        ),
      ],
    );
  }
}
