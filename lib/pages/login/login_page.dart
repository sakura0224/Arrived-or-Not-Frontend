import 'package:flutter/material.dart';
import '../teacher/root.dart';
import '../student/root.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 不显示右上角的 debug
      title: '登录界面',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // 注册路由表
      home: const LoginPageState(title: '登录'),
    );
  }
}

class LoginPageState extends StatefulWidget {
  const LoginPageState({super.key, required this.title});
  final String title;

  @override
  State<LoginPageState> createState() => _LoginPageStateState();
}

class _LoginPageStateState extends State<LoginPageState> {
  final GlobalKey _formKey = GlobalKey<FormState>();
  late String _studentNumber, _password;
  bool _isObscure = true;
  Color _eyeColor = Colors.grey;

  Future<void> _stulogin(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('stuLoggedIn', true);
    await prefs.setBool('teaLoggedIn', false);
  }

  Future<void> _tealogin(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('stuLoggedIn', false);
    await prefs.setBool('teaLoggedIn', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: kToolbarHeight), // 距离顶部一个工具栏的高度
            buildTitle(), // Login
            const SizedBox(height: 60),
            buildStudentNumberTextField(), // 输入学工号
            const SizedBox(height: 30),
            buildPasswordTextField(context), // 输入密码
            buildForgetPasswordText(context), // 忘记密码
            const SizedBox(height: 60),
            buildStudentLoginButton(context, 'student'), // 登录按钮
            const SizedBox(height: 30),
            buildTeacherLoginButton(context, 'teacher'),
            const SizedBox(height: 40),
            buildOtherLoginText(), // 其他账号登录
            buildRegisterText(context), // 注册
          ],
        ),
      ),
    );
  }

//学工号输入端
  Widget buildStudentNumberTextField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: '请输入学/工号'),
      validator: (v) {
        var studentNumberPattern = r'^\d{8}$'; // 假设学号为8位数字
        RegExp studentNumberRegExp = RegExp(studentNumberPattern);
        if (!studentNumberRegExp.hasMatch(v!)) {
          return '请输入正确的学号';
        }
        return null;
      },
      onSaved: (v) => _studentNumber = v!,
    );
  }

//密码输入端
  Widget buildPasswordTextField(BuildContext context) {
    return TextFormField(
        obscureText: _isObscure, // 是否显示文字
        onSaved: (v) => _password = v!,
        validator: (v) {
          if (v!.isEmpty) {
            return '请输入密码';
          }
          return null;
        },
        decoration: InputDecoration(
            labelText: "请输入密码",
            suffixIcon: IconButton(
              icon: Icon(
                Icons.remove_red_eye,
                color: _eyeColor,
              ),
              onPressed: () {
                // 修改 state 内部变量, 且需要界面内容更新, 需要使用 setState()
                setState(() {
                  _isObscure = !_isObscure;
                  _eyeColor = (_isObscure
                      ? Colors.grey
                      : Theme.of(context).iconTheme.color)!;
                });
              },
            )));
  }

//标题
  Widget buildTitle() {
    return const Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          '到没到',
          style: TextStyle(fontSize: 42),
        ));
  }

//学生登录按钮
  Widget buildStudentLoginButton(BuildContext context, String userType) {
    return Align(
      child: SizedBox(
        height: 45,
        width: 270,
        child: ElevatedButton(
          style: ButtonStyle(
              // 设置圆角
              shape: MaterialStateProperty.all(const StadiumBorder(
                  side: BorderSide(style: BorderStyle.none))),
              // 设置按钮颜色为蓝色
              backgroundColor: MaterialStateProperty.all(
                  const Color.fromARGB(255, 228, 151, 177))),
          child: Text('学生登录',
              style: Theme.of(context).primaryTextTheme.headlineSmall),
          onPressed: () {
            // 表单校验通过才会继续执行
            // if ((_formKey.currentState as FormState).validate()) {
            //   (_formKey.currentState as FormState).save();
            //   //TODO 执行登录方法
            //   print('studentnunber: $_studentNumber, password: $_password');
            //   if (userType == 'student') {
            //     // 学生登录逻辑
            _stulogin(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const StuApp()),
            );
            // } else if (userType == 'teacher') {
            //   // 教师登录逻辑
            // }
            // }
          },
        ),
      ),
    );
  }

//教师登录按钮
  Widget buildTeacherLoginButton(BuildContext context, String userType) {
    return Align(
      child: SizedBox(
        height: 45,
        width: 270,
        child: ElevatedButton(
          style: ButtonStyle(
              // 设置圆角
              shape: MaterialStateProperty.all(const StadiumBorder(
                  side: BorderSide(style: BorderStyle.none))),
              // 设置按钮颜色为蓝色
              backgroundColor: MaterialStateProperty.all(
                  const Color.fromARGB(255, 228, 151, 177))),
          child: Text('教师登录',
              style: Theme.of(context).primaryTextTheme.headlineSmall),
          onPressed: () {
            // 表单校验通过才会继续执行
            // if ((_formKey.currentState as FormState).validate()) {
            //   (_formKey.currentState as FormState).save();
            //   //TODO 执行登录方法
            //   print('studentnunber: $_studentNumber, password: $_password');
            //   if (userType == 'student') {
            //     // 学生登录逻辑
            //   } else if (userType == 'teacher') {
            // 教师登录逻辑
            _tealogin(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TeaApp()),
            );
            //   }
            // }
          },
        ),
      ),
    );
  }

  Widget buildRegisterText(context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('没有账号?'),
            GestureDetector(
              child: const Text('点击注册', style: TextStyle(color: Colors.green)),
              onTap: () {
                print("点击注册");
              },
            )
          ],
        ),
      ),
    );
  }

  Widget buildOtherLoginText() {
    return const Center(
      child: Text(
        '其他账号登录',
        style: TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }

  Widget buildForgetPasswordText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {
            // Navigator.pop(context);
            print("忘记密码");
          },
          child: const Text("忘记密码？",
              style: TextStyle(fontSize: 14, color: Colors.grey)),
        ),
      ),
    );
  }

  Widget buildTitleLine() {
    return Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 4.0),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            color: Colors.black,
            width: 40,
            height: 2,
          ),
        ));
  }
}
