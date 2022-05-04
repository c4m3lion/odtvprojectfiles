// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class BetterVideoPage extends StatefulWidget {
  const BetterVideoPage({Key? key}) : super(key: key);

  @override
  BetterVideoPageState createState() => BetterVideoPageState();
}

class BetterVideoPageState extends State<BetterVideoPage> {
  late BetterPlayerController _betterPlayerController;
  bool isLandscape = false;
  int indexOpenCard = -1;
  int currentActiveEPG = 0;
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
              playerTheme: BetterPlayerTheme.cupertino,
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
                }),
              ]),
        ),
        betterPlayerDataSource: betterPlayerDataSource);
  }

  int _scrollToIndex() {
    for (int i = 0; i <= MyNetwork.currectEPG.length; i++) {
      bool temp = DateTime.now().isAfter(MyNetwork.currectEPG[i].startDate) &&
          DateTime.now().isBefore(MyNetwork.currectEPG[i].endDate);

      if (temp) {
        currentActiveEPG = i;
        if (i > 0) {
          return i - 1;
        }
        return i;
      }
    }
    currentActiveEPG = 0;
    return 0;
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
        body: Column(
          children: <Widget>[
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 200,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: BetterPlayer(
                        controller: _betterPlayerController,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back),
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(
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
            Expanded(
              child: ScrollablePositionedList.builder(
                initialScrollIndex: _scrollToIndex(),
                itemCount: MyNetwork.currectEPG.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: currentActiveEPG == index ? Colors.cyan : null,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Column(
                              children: [
                                Text(MyNetwork.currectEPG[index].startdt),
                                Text(DateFormat('dd/MM').format(
                                    MyNetwork.currectEPG[index].startDate)),
                              ],
                            ),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
