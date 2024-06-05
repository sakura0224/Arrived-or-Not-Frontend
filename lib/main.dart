import 'package:daomeidao/root.dart';
import 'package:flutter/material.dart';
import 'login/screens/home_screen.dart';
import 'login/screens/login_screen.dart';
import 'login/screens/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'global_config.dart';
import 'state_notifier.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfig.loadServerSettings();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? userType = prefs.getString('userType');
  runApp(
    ChangeNotifierProvider(
      create: (context) => StateNotifier(),
      child: MyApp(userType: userType),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? userType;
  const MyApp({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: userType == null ? const HomeScreen() : Root(userType: userType),
      routes: {
        HomeScreen.id: (context) => const HomeScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        SignUpScreen.id: (context) => const SignUpScreen(),
      },
    );
  }
}
