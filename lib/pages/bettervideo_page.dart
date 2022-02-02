// ignore_for_file: prefer_const_constructors

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
          fullScreenByDefault: true,
          allowedScreenSleep: false,
          fit: BoxFit.fill,
          deviceOrientationsOnFullScreen: [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
            DeviceOrientation.portraitDown,
            DeviceOrientation.portraitUp,
          ],
          controlsConfiguration: BetterPlayerControlsConfiguration(
              playerTheme: BetterPlayerTheme.cupertino,
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
    return OrientationBuilder(
      builder: (context, orientation) {
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text(MyNetwork.currentChanel.name),
              actions: [
                IconButton(
                  icon: const Icon(Icons.favorite_outline),
                  onPressed: () {
                    Navigator.pushNamed(context, '/search');
                  },
                ),
              ],
            ),
            body: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: BetterPlayer(
                  controller: _betterPlayerController,
                ),
              ),
            ),
            drawer: Drawer(
              backgroundColor: MyColors.black,
              // Add a ListView to the drawer. This ensures the user can scroll
              // through the options in the drawer if there isn't enough vertical
              // space to fit everything.
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(
                    height: 120,
                    child: DrawerHeader(
                      decoration: BoxDecoration(
                        color: MyColors.yellow,
                      ),
                      child: Text(
                        "User: " + MyNetwork.userInfo,
                        style: TextStyle(
                          fontSize: 30,
                          color: MyColors.black,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Card(
                      color: MyColors.yellow,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const <Widget>[
                          ListTile(
                            leading: Icon(Icons.tv),
                            title: Text('Channels'),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      // Update the state of the app
                      // ...
                      // Then close the drawer
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Card(
                      color: MyColors.yellow,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const <Widget>[
                          ListTile(
                            leading: Icon(Icons.favorite),
                            title: Text('Favorites'),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      // Update the state of the app
                      // ...
                      // Then close the drawer
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
