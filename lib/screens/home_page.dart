import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';
import 'package:odtvprojectfiles/screens/overlay_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late BetterPlayerController _betterPlayerController;
  FocusNode focusNodeVid = FocusNode();
  FocusNode focusNodeInfo = FocusNode();
  bool loading = false;
  bool isOverLay = false;
  bool isInfoOverLay = false;

  void changeVideo(int value) {
    _betterPlayerController.dispose();
    MyNetwork().changeChannel(value);
    onInitVideo();
  }

  void changeToVideo() {
    _betterPlayerController.dispose();
    onInitVideo();
  }

  void onInitVideo() async {
    loading = true;
    toggleInfo();
    MyNetwork.currentChanel.playBackUrl = await MyNetwork().getPlayBack();
    await MyNetwork().getEPG();
    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      MyNetwork.currentChanel.playBackUrl,
      liveStream: true,
    );
    _betterPlayerController = BetterPlayerController(
      const BetterPlayerConfiguration(
        autoPlay: true,
        //fullScreenByDefault: true,
        allowedScreenSleep: false,
        fit: BoxFit.fill,
        expandToFill: true,
        fullScreenAspectRatio: 16 / 9,
        aspectRatio: 16 / 9,
        deviceOrientationsOnFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        controlsConfiguration: BetterPlayerControlsConfiguration(
          playerTheme: BetterPlayerTheme.material,
          enableProgressBar: false,
          enableProgressText: false,
          enableSkips: false,
          enableFullscreen: false,
          enablePlaybackSpeed: false,
          enableAudioTracks: false,
          showControls: false,
        ),
      ),
      betterPlayerDataSource: betterPlayerDataSource,
    );
    setState(() {
      loading = false;
    });
  }

  void showOverlay() {
    isOverLay = !isOverLay;
    setState(() {});
  }

  void toggleInfo({value = true}) async {
    isInfoOverLay = value;
    setState(() {});
    if (!value) return;
    await Future.delayed(Duration(seconds: 6));
    isInfoOverLay = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    focusNodeVid = FocusNode(onKey: (node, RawKeyEvent event) {
      if (isOverLay) return KeyEventResult.ignored;
      print(event.logicalKey.debugName);
      print(event.data.keyLabel);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(event.logicalKey.debugName.toString())),
      );
      if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
          event.isKeyPressed(LogicalKeyboardKey.select) ||
          (event.logicalKey.keyLabel == "Select" &&
              event.runtimeType.toString() == 'RawKeyDownEvent')) {
        showOverlay();
      }
      if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) ||
          event.isKeyPressed(LogicalKeyboardKey.channelDown)) {
        changeVideo(1);
      }
      if (event.isKeyPressed(LogicalKeyboardKey.arrowUp) ||
          event.isKeyPressed(LogicalKeyboardKey.channelUp)) {
        changeVideo(-1);
      }
      if (event.isKeyPressed(LogicalKeyboardKey.space) ||
          event.isKeyPressed(LogicalKeyboardKey.contextMenu)) {
        toggleInfo(value: !isInfoOverLay);
        setState(() {});
      }
      return KeyEventResult.handled;
    });
    onInitVideo();
  }

  @override
  void dispose() {
    super.dispose();
    _betterPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print('The user tries to pop()');
        showOverlay();
        return false;
      },
      child: Scaffold(
        body: Stack(
          alignment: Alignment.topLeft,
          children: [
            InkWell(
              autofocus: true,
              focusNode: focusNodeVid,
              onFocusChange: (value) => {
                if (!value) FocusScope.of(context).requestFocus(focusNodeVid),
              },
              onTap: isOverLay
                  ? null
                  : () => {
                        //showOverlay(),
                      },
              child: SizedBox(),
            ),
            Center(
              child: loading
                  ? const CircularProgressIndicator()
                  : AspectRatio(
                      aspectRatio: 16 / 9,
                      child: BetterPlayer(
                        controller: _betterPlayerController,
                      ),
                    ),
            ),
            isInfoOverLay ? InfoOverLay(context) : SizedBox(),
            isOverLay ? OverlayPage(changeToVideo) : SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget InfoOverLay(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        child: ListTile(
          leading: FadeInImage.assetNetwork(
            placeholder: "assets/images/page.png",
            image: MyNetwork.currentChanel.icon,
          ),
          title: Text(MyNetwork.currentChanel.name),
        ),
      ),
    );
  }
}
