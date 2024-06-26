// 横幅组件

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher_string.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  BannerWidgetState createState() => BannerWidgetState();
}

class BannerWidgetState extends State<BannerWidget> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      if (_currentPage < 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _controller.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _launchURL(url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SizedBox(
          height: 200.0,
          child: PageView(
            controller: _controller,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: <Widget>[
              GestureDetector(
                onTap: () => _launchURL('https://www.shu.edu.cn'),
                child: Image.asset(
                  'assets/banner/school.png',
                  fit: BoxFit.cover,
                ),
              ),
              GestureDetector(
                onTap: () => _launchURL('https://www.baidu.com'),
                child: Image.asset(
                  'assets/banner/museum.png',
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 10.0,
          right: 10.0,
          child: Row(
            children: List.generate(2, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index ? Colors.blue : Colors.grey,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
