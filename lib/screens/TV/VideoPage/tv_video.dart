import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loading_gifs/loading_gifs.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';
import 'package:odtvprojectfiles/mylibs/myVideoFunctions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TvVideo extends StatefulWidget {
  @override
  State<TvVideo> createState() => _TvVideoState();
}

class _TvVideoState extends State<TvVideo> {
  BetterPlayerController? _videoController;
  late BetterPlayerConfiguration _videoConfig;
  bool loading = false;

  Widget currentVideoState = SizedBox();

  void loadPlaybackIfNotExist() async {
    String _url =
        await MyNetwork().getPlayBack(channel_id: MyNetwork.currentChanel.id);
    if (_url == MyNetwork.currentChanel.playBackUrl) {
      return;
    }
    MyNetwork.currentChanel.playBackUrl = _url;
    setCurrentVideo();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("${MyNetwork.currentChanel.id}vid",
        MyNetwork.currentChanel.playBackUrl);
  }

  void setVideo(String _url) {
    loading = true;
    MyNetwork().getEPG();
    loadPlaybackIfNotExist();
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

    MyVideoFunctions.videoController = _videoController;
    setState(() {
      loading = false;
    });
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
      allowedScreenSleep: true,
      fit: BoxFit.fill,
      expandToFill: true,
      fullScreenAspectRatio: MyVideoFunctions.aspectRatio,
      aspectRatio: MyVideoFunctions.aspectRatio,
      deviceOrientationsOnFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      controlsConfiguration: const BetterPlayerControlsConfiguration(
        enableOverflowMenu: true,
        playerTheme: BetterPlayerTheme.material,
        enableProgressBar: false,
        enableProgressText: false,
        enableSkips: false,
        enableFullscreen: false,
        enablePlaybackSpeed: false,
        enableAudioTracks: false,
        showControls: false,
      ),
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
    return Center(
      child: AspectRatio(
        aspectRatio: MyVideoFunctions.aspectRatio,
        child: loading
            ? const CircularProgressIndicator()
            : BetterPlayer(controller: _videoController!),
      ),
    );
  }
}
