import 'package:flutter/material.dart';

class AppPage extends StatelessWidget {
  final String title;

  const AppPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const Center(
        child: Text(
          '占位符页面',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
