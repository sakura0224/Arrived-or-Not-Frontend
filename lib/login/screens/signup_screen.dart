import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/components.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import '../constants.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:http/http.dart' as http;
import '../../global_config.dart';
import '../../functions/handshake.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  static String id = 'signup_screen';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late String _number;
  late String _password;
  late String _name;
  late String _confirmPass;
  String _userType = '';
  bool _saving = false;

  Future<void> register(String userType, BuildContext context) async {
    userType = _userType;
    HandshakeStatus status = await sendHandshakeRequest();
    if (status != HandshakeStatus.success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('目标服务器无响应')),
        );
        setState(() {
          _saving = false;
        });
      }
    } else {
      var url = Uri.parse(
          'http://${GlobalConfig.serverIpAddress}:${GlobalConfig.serverPort}/register');
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // 设置 Content-Type 请求头
        },
        body: jsonEncode({
          'number': _number,
          'usertype': userType,
          'name': _name,
          'password': _password,
        }),
      );
      if (response.statusCode == 400) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('账户已存在，请直接登录')));
          setState(() {
            _saving = false;
          });
        }
      } else if (response.statusCode != 201) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('注册失败: ${response.statusCode}')),
          );
          setState(() {
            _saving = false;
          });
        }
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TopScreenImage(screenImageName: 'signup.png'),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const ScreenTitle(title: '注册'),
                          CustomTextField(
                            textField: TextField(
                              onChanged: (value) {
                                _name = value;
                              },
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                              decoration: kTextInputDecoration.copyWith(
                                hintText: '姓名',
                              ),
                            ),
                          ),
                          CustomTextField(
                            textField: TextField(
                              onChanged: (value) {
                                _number = value;
                              },
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                              decoration: kTextInputDecoration.copyWith(
                                hintText: '学/工号',
                              ),
                            ),
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
                              decoration: kTextInputDecoration.copyWith(
                                hintText: '密码',
                              ),
                            ),
                          ),
                          CustomTextField(
                            textField: TextField(
                              obscureText: true,
                              onChanged: (value) {
                                _confirmPass = value;
                              },
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                              decoration: kTextInputDecoration.copyWith(
                                hintText: '再次输入密码',
                              ),
                            ),
                          ),
                          CustomBottomScreen(
                            textButton: '注册',
                            heroTag: 'signup_btn',
                            question: '已有账号？',
                            buttonPressed: () async {
                              FocusManager.instance.primaryFocus?.unfocus();

                              if (_confirmPass != _password) {
                                showAlert(
                                    context: context,
                                    title: '密码不匹配',
                                    desc: '请确认您输入的两次密码一致',
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }).show();
                              } else {
                                try {
                                  await chooseType(
                                          onPressed1: () {
                                            _userType = 'student';
                                            Navigator.of(context).pop();
                                          },
                                          onPressed2: () {
                                            _userType = 'teacher';
                                            Navigator.of(context).pop();
                                          },
                                          title: '用户类型',
                                          desc: '请选择您的用户类型',
                                          btnText1: '学生',
                                          btnText2: '教师',
                                          context: context)
                                      .show()
                                      .then((_) {
                                    setState(() {
                                      _saving = true;
                                    });
                                    register(_userType, context);
                                  });

                                  if (context.mounted) {
                                    signUpAlert(
                                      context: context,
                                      title: '注册成功',
                                      desc: '现在即可登录',
                                      btnText: '立即登录',
                                      onPressed: () {
                                        setState(() {
                                          _saving = false;
                                          Navigator.popAndPushNamed(
                                              context, SignUpScreen.id);
                                        });
                                        Navigator.pushNamed(
                                            context, LoginScreen.id);
                                      },
                                    ).show();
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    signUpAlert(
                                        context: context,
                                        title: '出错了',
                                        desc: '网络错误，请稍后再试',
                                        btnText: '关闭',
                                        onPressed: () {
                                          SystemNavigator.pop();
                                        }).show();
                                  }
                                }
                              }
                            },
                            questionPressed: () async {
                              Navigator.pushNamed(context, LoginScreen.id);
                            },
                          ),
                        ],
                      ),
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
