// 导入相关的包
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'global_config.dart';

// 程序入口
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfig.loadServerSettings();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ImageNotifier(),
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
        primarySwatch: Colors.blue,
      ),
      home: DefaultTabController(
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
  }
}

// 用于传递图片的Provider
class ImageNotifier extends ChangeNotifier {
  XFile? _image;

  XFile? get image => _image;

  void setImage(XFile image) {
    _image = image;
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
  bool _isUploading = false;

  Future<void> getImage(ImageNotifier imageNotifier) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      imageNotifier.setImage(image);
    }
  }

// 上传图片
  Future<void> uploadImage(String imagePath, BuildContext context) async {
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
    });

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      var uri = Uri.parse(
          'http://${GlobalConfig.serverIpAddress}:${GlobalConfig.serverPort}/upload');
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('image', imagePath));

      var response = await request.send();

      if (response.statusCode == 200) {
        response.stream.transform(utf8.decoder).listen((value) {
          Map<String, dynamic> result = jsonDecode(value);
          if (result['image'] != null) {
            Uint8List bytes = base64Decode(result['image']);
            // 假设服务器返回的数据是有效的
            bool shouldAddRecord = result['image'] != null;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewPage(
                  image: bytes,
                  text: result['size'] != null ? result['size'].toString() : '未知尺寸',
                  shouldAddRecord: shouldAddRecord, // 传递这个标志
                ),
              ),
            );
          } else {
            scaffoldMessenger.showSnackBar(const SnackBar(content: Text('服务器返回的数据不完整')));
          }
        });
      } else {
        scaffoldMessenger.showSnackBar(const SnackBar(content: Text('图片上传失败')));
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('图片上传失败：$e')));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageNotifier = Provider.of<ImageNotifier>(context, listen: false);

    return Scaffold(
      body: Consumer<ImageNotifier>(
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
                      Text(
                        '点击拍摄照片，长按进行上传',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Image.file(File(imageNotifier.image!.path));
        },
      ),
      floatingActionButton: GestureDetector(
        onLongPress: () async {
          if (_isUploading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('图片正在上传中，请稍候...')),
            );
            return;
          }
          if (imageNotifier.image == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('请先拍摄照片')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('正在上传图片...')),
            );
            await uploadImage(imageNotifier.image!.path, context);
          }
        },
        child: FloatingActionButton(
          child: const Icon(Icons.camera),
          onPressed: () => getImage(imageNotifier),
        ),
      ),
    );
  }
}

// 识别弹出的页面
class NewPage extends StatefulWidget {
  final Uint8List image;
  final String text;
  final bool shouldAddRecord; // 添加这个参数

  const NewPage({super.key, required this.image, required this.text, this.shouldAddRecord = false});

  @override
  NewPageState createState() => NewPageState();
}

class NewPageState extends State<NewPage> {
  @override
  void initState() {
    super.initState();
    if (widget.shouldAddRecord) { // 根据标志决定是否添加记录
      addRecord();
    }
  }

  void addRecord() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> records = prefs.getStringList('records') ?? [];
    String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    records.add('${base64Encode(widget.image)}|${widget.text}|$now');
    await prefs.setStringList('records', records);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('识别结果'),
      ),
      body: Column(
        children: <Widget>[
          Image.memory(widget.image),
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
    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        List<String> parts = records[index].split('|');
        if (parts.length < 3) {
          return const ListTile(
            title: Text('记录不完整'),
          );
        }
        Uint8List image = base64Decode(parts[0]);
        String text = parts[1];
        String time = parts[2];
        return ListTile(
          leading: Image.memory(image, width: 50, height: 50),
          title: Text(time),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewPage(
                  key: UniqueKey(),
                  image: image,
                  text: text,
                ),
              ),
            );
          },
        );
      },
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
      ],
    );
  }
}
