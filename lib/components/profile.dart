import 'package:flutter/material.dart';
import 'dart:convert';

class Avatar extends StatelessWidget {
  final String name;
  final String number;
  final String avatar;
  const Avatar(
      {super.key,
      required this.name,
      required this.number,
      required this.avatar});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        foregroundImage:
            avatar.isNotEmpty ? MemoryImage(base64Decode(avatar)) : null,
        backgroundImage: const AssetImage('assets/avatar.png'),
      ),
      title: Text(name),
      subtitle: Text(number),
    );
  }
}

class Profile extends StatelessWidget {
  final String name;
  final String number;
  const Profile({super.key, required this.name, required this.number});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.account_box),
      title: const Text('账户信息'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfilePage(name: name, number: number)),
        );
      },
    );
  }
}

class ProfilePage extends StatelessWidget {
  final String name;
  final String number;
  const ProfilePage({super.key, required this.name, required this.number});

  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
        title: const Text('账户信息'),
      ),
      body: const Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
              labelText: '姓名',
            ),
            enabled: false,
          ),
          TextField(
            decoration: InputDecoration(
              labelText: '学/工号',
              // helperText: name,
            ),
            enabled: false,
          ),
          TextField(
            decoration: InputDecoration(
              labelText: '当前密码',
            ),
            obscureText: true,
          ),
          TextField(
            decoration: InputDecoration(
              labelText: '重置密码',
            ),
            obscureText: true,
          ),
        ],
      ),
    );
  }
}
