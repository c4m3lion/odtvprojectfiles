import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({Key? key}) : super(key: key);

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  bool isReady = false;

  void playVideo() async {
    videoPlayerController =
        VideoPlayerController.network(MyNetwork.currentChanel.playBackUrl);
    await videoPlayerController.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
    );
    setState(() {
      isReady = true;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    playVideo();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isReady
          ? Chewie(
              controller: chewieController,
            )
          : CircularProgressIndicator(),
    );
  }
}
