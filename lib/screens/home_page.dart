import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
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
  bool isNumberOverlay = false;
  bool isFavPressed = false;

  int timer = 0;
  int numberPressed = 0;

  void changeChanneltoNumber(int id) {
    timer += 1;
    numberPressed = numberPressed * 10 + id;
    if (timer >= 4 || numberPressed > MyNetwork.channels.length) {
      timer = 0;
      numberPressed = 0;
      isNumberOverlay = false;
      setState(() {});
      return;
    }
    if (numberPressed == 0) {
      numberPressed = 1;
    }
    loadChannelByNumber(numberPressed - 1);
    isNumberOverlay = true;
    setState(() {});
  }

  void loadChannelByNumber(int id) async {
    var temp = timer;
    await Future.delayed(Duration(seconds: 3));
    if (timer == temp) {
      MyLocalData.selectedCurrentTag = 1;
      MyNetwork.currentChanel = MyNetwork.channels[id];

      timer = 0;
      numberPressed = 0;
      isNumberOverlay = false;
      setState(() {});
      changeToVideo();
    }
  }

  void changeVideo(int value) {
    _betterPlayerController.dispose();
    MyNetwork().changeChannel(value);
    onInitVideo();
  }

  void changeToVideo() {
    if (_betterPlayerController == null) {
      onInitVideo();
    } else {
      _betterPlayerController.dispose();
      onInitVideo();
    }
  }

  void loadOtherStuff() async {
    await MyNetwork().getFavorites();
    await MyNetwork().getEPG();
  }

  void onInitVideo() {
    loadOtherStuff();
    loading = true;
    toggleInfo();

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

  String getCurrentEPG() {
    for (int i = 0; i < MyNetwork.currectEPG.length; i++) {
      bool temp = DateTime.now().isAfter(MyNetwork.currectEPG[i].startDate) &&
          DateTime.now().isBefore(MyNetwork.currectEPG[i].endDate);

      if (temp) {
        return MyNetwork.currectEPG[i].title;
      }
    }
    return "";
  }

  void toggleInfo({value = true}) async {
    isInfoOverLay = value;
    setState(() {});
    if (!value) return;
    await Future.delayed(Duration(seconds: 6));
    isInfoOverLay = false;
    setState(() {});
  }

  void addFav({required String id}) async {
    isFavPressed = true;
    setState(() {});
    if (!MyNetwork.currentChanel.isFavorite) {
      String k = await MyNetwork().addFavorite(channel_id: id);
      if (k == "OK") {
        MyNetwork.currentChanel.isFavorite = true;
      }
    } else {
      String k = await MyNetwork().removeFavorite(channel_id: id);
      if (k == "OK") {
        MyNetwork.currentChanel.isFavorite = false;
      }
    }
    isFavPressed = false;
    setState(() {});
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  @override
  void initState() {
    super.initState();
    focusNodeVid = FocusNode(onKey: (node, RawKeyEvent event) {
      if (isOverLay) return KeyEventResult.ignored;
      print(event.logicalKey.debugName);
      print(event.data.keyLabel);
      print(isOverLay);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(event.logicalKey.debugName.toString())),
      // );
      if (event.isKeyPressed(LogicalKeyboardKey.goBack) && !isOverLay) {
        Navigator.pushReplacementNamed(context, '/mainhome');
      }
      if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
          event.isKeyPressed(LogicalKeyboardKey.select) ||
          (event.logicalKey.keyLabel == "Select" &&
              event.runtimeType.toString() == 'RawKeyDownEvent')) {
        if (!isInfoOverLay) {
          showOverlay();
        } else {
          addFav(id: MyNetwork.currentChanel.id);
        }
      }
      if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) ||
          event.isKeyPressed(LogicalKeyboardKey.channelDown)) {
        changeVideo(-1);
      }
      if (event.isKeyPressed(LogicalKeyboardKey.arrowUp) ||
          event.isKeyPressed(LogicalKeyboardKey.channelUp)) {
        changeVideo(1);
      }
      if (event.isKeyPressed(LogicalKeyboardKey.space) ||
          event.isKeyPressed(LogicalKeyboardKey.contextMenu)) {
        toggleInfo(value: !isInfoOverLay);
        setState(() {});
      }
      if (isNumeric(event.logicalKey.keyLabel) &&
          event.runtimeType.toString() == 'RawKeyDownEvent') {
        MyPrint.printWarning(event.logicalKey.keyLabel);
        changeChanneltoNumber(int.parse(event.logicalKey.keyLabel));
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
        if (!isOverLay) {}
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
            isNumberOverlay ? NumberOverLay(context) : SizedBox(),
            isOverLay ? OverlayPage(changeToVideo) : SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget InfoOverLay(BuildContext context) {
    return Container(
      child: Card(
        child: ListTile(
          leading: FadeInImage.assetNetwork(
            placeholder: "assets/images/page.png",
            image: MyNetwork.currentChanel.icon,
            imageErrorBuilder: (context, error, stackTrace) {
              return Image.asset('assets/images/page.png',
                  fit: BoxFit.fitWidth);
            },
          ),
          title: Text(MyNetwork.currentChanel.name),
          subtitle: Text(getCurrentEPG()),
          trailing: MyNetwork.currentChanel.isFavorite
              ? Icon(Icons.favorite)
              : Icon(Icons.favorite_border_outlined),
        ),
      ),
    );
  }

  Widget NumberOverLay(BuildContext context) {
    return Container(
      child: Card(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          numberPressed.toString(),
          style: TextStyle(fontSize: 35),
        ),
      )),
    );
  }
}
