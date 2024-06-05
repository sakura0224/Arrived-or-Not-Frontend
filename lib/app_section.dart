import 'package:flutter/material.dart';

abstract class AppData {
  String get title;

  List<IconData> get icons;

  List<String> get names;

  List<Widget> get pages;
}

class NoData extends AppData {
  @override
  final String title = '0';

  @override
  final List<IconData> icons = [];

  @override
  final List<String> names = [];

  @override
  final List<Widget> pages = [];
}

class AppSection extends StatelessWidget {
  final String title;
  final List<IconData> icons;
  final List<String> names;
  final List<Widget> pages;

  const AppSection(
      {super.key,
      required this.title,
      required this.icons,
      required this.names,
      required this.pages});

  @override
  Widget build(BuildContext context) {
    if (title == '0') {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5.0,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(icons.length, (index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => pages[index]));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        icons[index],
                        size: 35,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        names[index],
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
