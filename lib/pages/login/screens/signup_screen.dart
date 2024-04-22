import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/components.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../constants.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:http/http.dart' as http;
import '../../../global_config.dart';
import '../../../functions/handshake.dart';

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
  late String _userType;
  bool _saving = false;

  Future<void> register(String number, String password, String confirmPass,
      String name, String userType, BuildContext context) async {
    _confirmPass = confirmPass;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _saving = true;
    });
    HandshakeStatus status = await sendHandshakeRequest();
    if (_confirmPass == _password) {
      if (status == HandshakeStatus.success) {
        try {
          var url = Uri.parse(
              'http://${GlobalConfig.serverIpAddress}:${GlobalConfig.serverPort}/users/register');
          var request = await http.post(url, body: {
            'number': number,
            'usertype': userType,
            'name': name,
            'password': password,
          });
          if (request.statusCode == 201) {
            if (context.mounted) {
              signUpAlert(
                context: context,
                title: '注册成功',
                desc: '现在即可登录',
                btnText: '立即登录',
                onPressed: () {
                  setState(() {
                    _saving = false;
                    Navigator.popAndPushNamed(context, SignUpScreen.id);
                  });
                  Navigator.pushNamed(context, LoginScreen.id);
                },
              ).show();
            } else {
              setState(() {
                _saving = false;
                Navigator.popAndPushNamed(context, SignUpScreen.id);
              });
            }
          }
        } catch (e) {
          if (context.mounted) {
            signUpAlert(
                context: context,
                onPressed: () {
                  SystemNavigator.pop();
                },
                title: '出错了',
                desc: '请关闭APP再次尝试',
                btnText: '关闭APP');
          }
        }
        setState(() {
          _saving = false;
        });
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('目标服务器无响应')),
          );
        }
      }
    } else {
      if (context.mounted) {
        showAlert(
            context: context,
            title: '密码不匹配',
            desc: '请确认您输入的两次密码一致',
            onPressed: () {
              Navigator.pop(context);
            }).show();
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
                              chooseType(
                                      onPressed1: () {
                                        _userType = 'student';
                                        register(
                                            _number,
                                            _password,
                                            _confirmPass,
                                            _name,
                                            _userType,
                                            context);
                                      },
                                      onPressed2: () {
                                        _userType = 'teacher';
                                        register(
                                            _number,
                                            _password,
                                            _confirmPass,
                                            _name,
                                            _userType,
                                            context);
                                      },
                                      title: '用户类型',
                                      desc: '请选择您的用户类型',
                                      btnText1: '学生',
                                      btnText2: '教师',
                                      context: context)
                                  .show();
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
