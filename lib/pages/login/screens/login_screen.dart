import 'package:daomeidao/pages/student/root.dart';
import 'package:daomeidao/pages/teacher/root.dart';
import 'package:flutter/material.dart';
import '../components/components.dart';
import '../constants.dart';
import 'package:loading_overlay/loading_overlay.dart';
import '../screens/home_screen.dart';
import 'package:http/http.dart' as http;
import '../../../global_config.dart';
import '../../../functions/handshake.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static String id = 'login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String _number;
  late String _password;
  bool _saving = false;

  Future<void> login(
      String number, String password, BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _saving = true;
    });
    HandshakeStatus status = await sendHandshakeRequest();
    if (status == HandshakeStatus.success) {
      try {
        var url = Uri.parse(
            'http://${GlobalConfig.serverIpAddress}:${GlobalConfig.serverPort}/users/login');
        var response = await http.post(url, body: {
          'number': number,
          'password': password,
        });

        if (response.statusCode == 200) {
          var result = jsonDecode(response.body); // 假设响应体中的令牌是在'token'键下
          var token = result['token'];
          var userType = result['usertype'];
          // 保存令牌到shared_preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwtToken', token);
          await prefs.setString('userType', userType);
          setState(() {
            _saving = false;
            if (userType == 'student') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StuApp()),
              );
            } else if (userType == 'teacher') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TeaApp()),
              );
            }
          });
        } else {
          if (response.statusCode == 401 && context.mounted) {
            signUpAlert(
              context: context,
              onPressed: () {
                setState(() {
                  _saving = false;
                });
                Navigator.popAndPushNamed(context, LoginScreen.id);
              },
              title: '学/工号或密码错误',
              desc: '请再次确认您的学/工号或密码',
              btnText: '重试',
            ).show();
          }
        }
      } catch (e) {
        if (context.mounted) {
          signUpAlert(
            context: context,
            onPressed: () {
              setState(() {
                _saving = false;
              });
              Navigator.popAndPushNamed(context, LoginScreen.id);
            },
            title: '学/工号或密码错误',
            desc: '请再次确认您的学/工号或密码',
            btnText: '重试',
          ).show();
        }
      }
    } else {
      setState(() {
        _saving = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('目标服务器无响应')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        Future.delayed(Duration.zero, () {
          Navigator.popAndPushNamed(context, HomeScreen.id);
        });
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LoadingOverlay(
          isLoading: _saving,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const TopScreenImage(screenImageName: 'welcome.png'),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const ScreenTitle(title: '登录'),
                        CustomTextField(
                          textField: TextField(
                              onChanged: (value) {
                                _number = value;
                              },
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                              decoration: kTextInputDecoration.copyWith(
                                  hintText: '学/工号')),
                        ),
                        CustomTextField(
                          textField: TextField(
                            obscureText: true,
                            onChanged: (value) {
                              _password = value;
                            },
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                            decoration:
                                kTextInputDecoration.copyWith(hintText: '密码'),
                          ),
                        ),
                        CustomBottomScreen(
                          textButton: '登录',
                          heroTag: 'login_btn',
                          question: '忘记密码？',
                          buttonPressed: () async {
                            login(_number, _password, context);
                          },
                          questionPressed: () {
                            signUpAlert(
                              onPressed: () async {
                                // Reset password
                              },
                              title: '重置密码',
                              desc: '点击按钮以重置密码',
                              btnText: '立即重置',
                              context: context,
                            ).show();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
