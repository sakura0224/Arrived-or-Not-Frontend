import 'package:flutter/material.dart';
import 'pages/login/screens/home_screen.dart';
import 'pages/login/screens/login_screen.dart';
import 'pages/login/screens/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/teacher/root.dart';
import 'pages/student/root.dart';
import 'global_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfig.loadServerSettings();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? userType = prefs.getString('userType');
  runApp(MyApp(userType: userType));
}

class MyApp extends StatelessWidget {
  final String? userType;
  const MyApp({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // theme: ThemeData(
      //     textTheme: const TextTheme(
      //   bodyMedium: TextStyle(
      //     fontFamily: 'Ubuntu',
      //   ),
      // )),
      home: userType == null
          ? const HomeScreen()
          : userType == 'teacher'
              ? const TeaApp()
              : userType == 'student'
                  ? const StuApp()
                  : const HomeScreen(),
      routes: {
        HomeScreen.id: (context) => const HomeScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        SignUpScreen.id: (context) => const SignUpScreen(),
      },
    );
  }
}
