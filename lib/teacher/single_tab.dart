import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'video_data.dart';
import 'vlc_player_with_controls.dart';
import 'package:path_provider/path_provider.dart';

class SingleTab extends StatefulWidget {
  const SingleTab({super.key});

  @override
  SingleTabState createState() => SingleTabState();
}

class SingleTabState extends State<SingleTab> {
  static const _networkCachingMs = 2000;
  static const _subtitlesFontSize = 30;
  static const _height = 400.0;

  final _key = GlobalKey<VlcPlayerWithControlsState>();

  // ignore: avoid-late-keyword
  late final VlcPlayerController _controller;

  //
  List<VideoData> listVideos = [
    const VideoData(
      name: '摄像头源',
      path:
          'rtsp://admin:Nb123456@192.168.43.168:554/stream1',
      type: VideoType.network,
    ),
    //
    const VideoData(
      name: '专注度检测',
      path: 'rtsp://admin:Nb123456@192.168.43.49:8554/stream1',
      type: VideoType.network,
    ),
  ];

  int selectedVideoIndex = 0;

  Future<File> _loadVideoToFs() async {
    final videoData = await rootBundle.load('assets/sample.mp4');
    final videoBytes = Uint8List.view(videoData.buffer);
    final dir = (await getTemporaryDirectory()).path;
    final temp = File('$dir/temp.file');
    temp.writeAsBytesSync(videoBytes);

    return temp;
  }

  @override
  void initState() {
    super.initState();

    //
    final initVideo = listVideos[selectedVideoIndex];
    switch (initVideo.type) {
      case VideoType.network:
        _controller = VlcPlayerController.network(
          initVideo.path,
          hwAcc: HwAcc.full,
          options: VlcPlayerOptions(
            advanced: VlcAdvancedOptions([
              VlcAdvancedOptions.networkCaching(_networkCachingMs),
            ]),
            subtitle: VlcSubtitleOptions([
              VlcSubtitleOptions.boldStyle(true),
              VlcSubtitleOptions.fontSize(_subtitlesFontSize),
              VlcSubtitleOptions.outlineColor(VlcSubtitleColor.yellow),
              VlcSubtitleOptions.outlineThickness(VlcSubtitleThickness.normal),
              // works only on externally added subtitles
              VlcSubtitleOptions.color(VlcSubtitleColor.navy),
            ]),
            http: VlcHttpOptions([
              VlcHttpOptions.httpReconnect(true),
            ]),
            rtp: VlcRtpOptions([
              VlcRtpOptions.rtpOverRtsp(true),
            ]),
          ),
        );
        break;
      case VideoType.file:
        final file = File(initVideo.path);
        _controller = VlcPlayerController.file(
          file,
        );
        break;
      case VideoType.asset:
        _controller = VlcPlayerController.asset(
          initVideo.path,
          options: VlcPlayerOptions(),
        );
        break;
      case VideoType.recorded:
        break;
    }
    _controller.addOnInitListener(() async {
      await _controller.startRendererScanning();
    });
    _controller.addOnRendererEventListener((type, id, name) {
      debugPrint('OnRendererEventListener $type $id $name');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          height: _height,
          child: VlcPlayerWithControls(
            key: _key,
            controller: _controller,
            onStopRecording: (recordPath) {
              setState(() {
                listVideos.add(
                  VideoData(
                    name: 'Recorded Video',
                    path: recordPath,
                    type: VideoType.recorded,
                  ),
                );
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'The recorded video file has been added to the end of list.',
                  ),
                ),
              );
            },
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: listVideos.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            final video = listVideos[index];
            IconData iconData;
            switch (video.type) {
              case VideoType.network:
                iconData = Icons.cloud;
                break;
              case VideoType.file:
                iconData = Icons.insert_drive_file;
                break;
              case VideoType.asset:
                iconData = Icons.all_inbox;
                break;
              case VideoType.recorded:
                iconData = Icons.videocam;
                break;
            }

            return ListTile(
              dense: true,
              selected: selectedVideoIndex == index,
              selectedTileColor: Colors.black54,
              leading: Icon(
                iconData,
                color:
                    selectedVideoIndex == index ? Colors.white : Colors.black,
              ),
              title: Text(
                video.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color:
                      selectedVideoIndex == index ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text(
                video.path,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color:
                      selectedVideoIndex == index ? Colors.white : Colors.black,
                ),
              ),
              onTap: () async {
                await _controller.stopRecording();
                switch (video.type) {
                  case VideoType.network:
                    await _controller.setMediaFromNetwork(
                      video.path,
                      hwAcc: HwAcc.full,
                    );
                    break;
                  case VideoType.file:
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('正在将文件拷贝至临时储存...'),
                        ),
                      );
                    }
                    await Future<void>.delayed(const Duration(seconds: 1));
                    final tempVideo = await _loadVideoToFs();
                    await Future<void>.delayed(const Duration(seconds: 1));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('正在尝试播放...'),
                        ),
                      );
                    }
                    await Future<void>.delayed(const Duration(seconds: 1));
                    if (await tempVideo.exists()) {
                      await _controller.setMediaFromFile(tempVideo);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('文件加载失败'),
                          ),
                        );
                      }
                    }
                    break;
                  case VideoType.asset:
                    await _controller.setMediaFromAsset(video.path);
                    break;
                  case VideoType.recorded:
                    final recordedFile = File(video.path);
                    await _controller.setMediaFromFile(recordedFile);
                    break;
                }
                setState(() {
                  selectedVideoIndex = index;
                });
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await _controller.stopRecording();
    await _controller.stopRendererScanning();
    await _controller.dispose();
  }
}
