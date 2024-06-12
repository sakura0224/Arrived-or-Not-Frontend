import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Avatar extends StatefulWidget {
  const Avatar({super.key});

  @override
  AvatarStatus createState() => AvatarStatus();
}

class AvatarStatus extends State<Avatar> {
  String name = '用户';
  String number = '10000000';
  String avatar = '';

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '用户';
      number = prefs.getString('number') ?? '10000000';
      avatar = prefs.getString('avatar') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        foregroundImage: avatar.isNotEmpty ? MemoryImage(base64Decode(avatar)) : null,
        backgroundImage: const AssetImage('assets/avatar.png'),
      ),
      title: Text(name),
      subtitle: Text(number),
    );
  }
}

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  ProfileStatus createState() => ProfileStatus();
}

class ProfileStatus extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.account_box),
      title: const Text('账户信息'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
      },
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
          ),
          TextField(
            decoration: InputDecoration(
              labelText: '学/工号',
            ),
          ),
        ],
      ),
    );
  }
}