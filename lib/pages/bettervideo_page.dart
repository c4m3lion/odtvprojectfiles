// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';
import 'package:odtvprojectfiles/pages/main_page.dart';

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
          fit: BoxFit.fitHeight,
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
            SliverAppBar(
              pinned: false,
              snap: false,
              floating: false,
              expandedHeight: 200.0,
              flexibleSpace: FlexibleSpaceBar(
                background: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: BetterPlayer(
                    controller: _betterPlayerController,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25.0),
                          child: FadeInImage.assetNetwork(
                              placeholder: 'assets/icons/loadingicon.png',
                              image: MyNetwork.currentChanel.icon),
                        ),
                      ),
                      Text(
                        MyNetwork.currentChanel.name,
                        style: TextStyle(color: MyColors.white, fontSize: 20),
                      ),
                      Expanded(child: SizedBox()),
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
                  return Container(
                    color: index.isOdd ? Colors.white : Colors.black12,
                    height: 100.0,
                    child: Center(
                      child: Text('$index', textScaleFactor: 5),
                    ),
                  );
                },
                childCount: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
