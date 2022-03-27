// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';

class BetterVideoPage extends StatefulWidget {
  const BetterVideoPage({Key? key}) : super(key: key);

  @override
  BetterVideoPageState createState() => BetterVideoPageState();
}

class BetterVideoPageState extends State<BetterVideoPage> {
  late BetterPlayerController _betterPlayerController;
  bool isLandscape = false;
  int indexOpenCard = -1;
  bool isFavPressed = false;
  void getVideo() {
    MyPrint.printWarning(MyNetwork.currentChanel.playBackUrl);
    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      MyNetwork.currentChanel.playBackUrl,
      liveStream: true,
    );
    _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
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
            DeviceOrientation.portraitDown,
            DeviceOrientation.portraitUp,
          ],
          controlsConfiguration: BetterPlayerControlsConfiguration(
              playerTheme: BetterPlayerTheme.material,
              enableProgressBar: false,
              enableProgressText: false,
              enableSkips: false,
              enableFullscreen: true,
              enablePlaybackSpeed: false,
              enableAudioTracks: false,
              showControls: false,
              overflowMenuCustomItems: [
                BetterPlayerOverflowMenuItem(
                    Icons.favorite_outline, "Add to favorites", () {}),
                BetterPlayerOverflowMenuItem(
                    Icons.info_outline, "Show Epg", () {})
              ]),
        ),
        betterPlayerDataSource: betterPlayerDataSource);
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

  void _showAlert(BuildContext context, int currentIdex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(MyNetwork.currectEPG[currentIdex].title),
        content: SingleChildScrollView(
            child: Text(MyNetwork.currectEPG[currentIdex].description)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getVideo();
  }

  @override
  void dispose() async {
    super.dispose();
    MyNetwork.isVideoPlaying = false;
    _betterPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Container(
                height: 200,
                color: Colors.black,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    InkWell(
                      onTap: () => {_betterPlayerController.toggleFullScreen()},
                      child: SizedBox(
                        height: 200,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: BetterPlayer(
                            controller: _betterPlayerController,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25.0),
                          child: FadeInImage.assetNetwork(
                              placeholder: 'assets/icons/loadingicon.png',
                              image: MyNetwork.currentChanel.icon),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          MyNetwork.currentChanel.name,
                          style: TextStyle(color: MyColors.black, fontSize: 18),
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ),
                      Expanded(child: SizedBox()),
                      IconButton(
                          onPressed: () =>
                              {_betterPlayerController.toggleFullScreen()},
                          icon: Icon(Icons.fullscreen)),
                      IconButton(
                        icon: MyNetwork.currentChanel.isFavorite
                            ? Icon(Icons.favorite)
                            : Icon(Icons.favorite_border_outlined),
                        onPressed: isFavPressed
                            ? null
                            : () => {
                                  addFav(id: MyNetwork.currentChanel.id),
                                },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return InkWell(
                    onTap: () => {},
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
                        color: index.isOdd ? Colors.white : Colors.grey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading:
                                  Text(MyNetwork.currectEPG[index].startdt),
                              title: Text(MyNetwork.currectEPG[index].title),
                              subtitle: Text(
                                MyNetwork.currectEPG[index].description,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(MyNetwork.currectEPG[index].enddt),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: MyNetwork.currectEPG.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
