import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../mylibs/myNetwork.dart';
import '../../../mylibs/myVideoFunctions.dart';

class PhoneVideo extends StatefulWidget {
  const PhoneVideo({Key? key}) : super(key: key);

  @override
  State<PhoneVideo> createState() => _PhoneVideoState();
}

class _PhoneVideoState extends State<PhoneVideo> {
  BetterPlayerController? _videoController;
  late BetterPlayerConfiguration _videoConfig;
  bool loading = false;

  Widget currentVideoState = SizedBox();

  void setVideo(String _url) {
    loading = true;
    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      MyNetwork.currentChanel.playBackUrl,
      videoFormat: BetterPlayerVideoFormat.hls,
      liveStream: true,
    );
    _videoController = BetterPlayerController(
      _videoConfig,
      betterPlayerDataSource: betterPlayerDataSource,
    );
    _videoController?.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
        _videoController?.retryDataSource();
      }
    });
    setState(() {
      loading = false;
    });
  }

  void addFav({required String id}) async {
    setState(() {});
    if (!MyNetwork.currentChanel.isFavorite) {
      MyNetwork.currentChanel.isFavorite = true;
      setState(() {});
      String k = await MyNetwork().addFavorite(channel_id: id);
      if (k == "OK") {
        MyNetwork.currentChanel.isFavorite = true;
      }
    } else {
      MyNetwork.currentChanel.isFavorite = false;
      setState(() {});
      String k = await MyNetwork().removeFavorite(channel_id: id);
      if (k == "OK") {
        MyNetwork.currentChanel.isFavorite = false;
      }
    }
    setState(() {});
  }

  void saveVideoLocally() async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    await storage.write(
        key: "currentChannel", value: MyNetwork.currentChanel.id.toString());
  }

  void setCurrentVideo() {
    if (_videoController != null) {
      _videoController!.dispose();
    }
    setVideo(MyNetwork.currentChanel.playBackUrl);
    saveVideoLocally();
  }

  void openVideoSetting() {
    //_videoController?.setControlsAlwaysVisible(true);
  }

  void changeAspectRatio(double aspect) {
    MyVideoFunctions.aspectRatio = aspect;
    _videoController?.setOverriddenAspectRatio(MyVideoFunctions.aspectRatio);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _videoConfig = BetterPlayerConfiguration(
      autoPlay: true,
      //fullScreenByDefault: true,
      allowedScreenSleep: false,
      fit: BoxFit.contain,
      expandToFill: true,
      fullScreenAspectRatio: 16 / 9,
      aspectRatio: 16 / 9,
      deviceOrientationsOnFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp,
      ],
      controlsConfiguration: BetterPlayerControlsConfiguration(
          controlBarColor: Colors.black.withOpacity(0.5),
          liveTextColor: Colors.transparent,
          playerTheme: BetterPlayerTheme.material,
          enableProgressBar: false,
          enableProgressText: false,
          enableSkips: false,
          enableFullscreen: true,
          enablePlaybackSpeed: false,
          enableAudioTracks: false,
          showControls: true,
          overflowMenuCustomItems: [
            BetterPlayerOverflowMenuItem(
                MyNetwork.currentChanel.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border_outlined,
                "Add to favorites", () {
              addFav(id: MyNetwork.currentChanel.id);
              setState(() {});
            }),
          ]),
    );
    setCurrentVideo();
    MyVideoFunctions.setVideo = setCurrentVideo;
    MyVideoFunctions.openSettingVideo = openVideoSetting;
    MyVideoFunctions.changeAspectRatio = changeAspectRatio;
  }

  @override
  void dispose() {
    super.dispose();
    _videoController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: MyVideoFunctions.aspectRatio,
      child: loading
          ? const CircularProgressIndicator()
          : BetterPlayer(controller: _videoController!),
    );
  }
}
