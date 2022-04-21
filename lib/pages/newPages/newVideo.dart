import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';
import 'package:odtvprojectfiles/pages/newPages/newMenu.dart';

class NewVideoPage extends StatefulWidget {
  const NewVideoPage({Key? key}) : super(key: key);

  @override
  State<NewVideoPage> createState() => _NewVideoPageState();
}

class _NewVideoPageState extends State<NewVideoPage> {
  late BetterPlayerController _betterPlayerController;
  bool isLandscape = false;
  int indexOpenCard = -1;
  bool isFavPressed = false;
  bool loaded = false;
  var focusNodeVid;

  bool isOverlay = false;
  void getVideo() async {
    loaded = false;
    MyNetwork.currentChanel.playBackUrl = await MyNetwork().getPlayBack();
    await MyNetwork().getEPG();
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
              overflowMenuCustomItems: [
                BetterPlayerOverflowMenuItem(
                    Icons.favorite_outline, "Add to favorites", () {}),
                BetterPlayerOverflowMenuItem(
                    Icons.info_outline, "Show Epg", () {})
              ]),
        ),
        betterPlayerDataSource: betterPlayerDataSource);
    setState(() {
      loaded = true;
    });
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

  void showOverLay() {
    isOverlay = !isOverlay;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    getVideo();
    focusNodeVid = new FocusNode();
  }

  @override
  void dispose() async {
    focusNodeVid.dispose();
    super.dispose();
    MyNetwork.isVideoPlaying = false;
    _betterPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          print('The user tries to pop()');
          isOverlay
              ? {
                  showOverLay(),
                  print(focusNodeVid.toString()),
                  focusNodeVid.unfocus(),
                }
              : Navigator.pushReplacementNamed(context, '/main');
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              InkWell(
                autofocus: true,
                focusNode: focusNodeVid,
                onFocusChange: (value) => {
                  if (!value) FocusScope.of(context).requestFocus(focusNodeVid),
                },
                onTap: isOverlay
                    ? null
                    : () => {
                          showOverLay(),
                        },
                child: !loaded
                    ? Center(child: CircularProgressIndicator())
                    : Center(
                        child: SizedBox(
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: BetterPlayer(
                              controller: _betterPlayerController,
                            ),
                          ),
                        ),
                      ),
              ),
              isOverlay ? OverLayVideo() : SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}

class OverLayVideo extends StatefulWidget {
  const OverLayVideo({Key? key}) : super(key: key);

  @override
  State<OverLayVideo> createState() => _OverLayVideoState();
}

class _OverLayVideoState extends State<OverLayVideo> {
  String searchQuery = "Search query";
  void updateSearchQuery(String newQuery) {
    if (MyNetwork.categorys[MyLocalData.selectedChannelPage].id == "channel") {
      MyNetwork.currentChannels = MyNetwork.channels;
    } else if (MyNetwork.categorys[MyLocalData.selectedChannelPage].id ==
        "favorites") {
      MyNetwork.currentChannels = MyNetwork.favorites;
    } else {
      MyNetwork.currentChannels = MyNetwork.channels
          .where(((element) => element.category.contains(newQuery)))
          .toList();
    }
    MyPrint.printWarning(
        MyNetwork.categorys[MyLocalData.selectedChannelPage].name);
    setState(() {
      searchQuery = newQuery;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              height: double.infinity,
              color: const Color(0xff000000).withOpacity(0.70),
              child: ListView.builder(
                physics: const ClampingScrollPhysics(),
                itemCount: MyNetwork.categorys.length,
                scrollDirection: Axis.vertical,
                controller: ScrollController(),
                itemBuilder: (context, index) {
                  return Material(
                    color: index == MyLocalData.selectedChannelPage
                        ? Colors.cyan.withOpacity(0.4)
                        : Colors.transparent,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10),
                      onTap: () => {
                        setState(() {
                          MyLocalData.selectedChannelPage = index;
                          updateSearchQuery(MyNetwork.categorys[index].id);
                        }),
                      },
                      selected: index == MyLocalData.selectedChannelPage,
                      title: Text(MyNetwork.categorys[index].name),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: const Color(0xff4A4A4A).withOpacity(0.70),
              child: ListView.builder(
                physics: const ClampingScrollPhysics(),
                itemCount: MyNetwork.currentChannels.length,
                controller: ScrollController(),
                itemBuilder: (context, index) {
                  print(MyNetwork.currentChannels[index].icon);
                  return Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10),
                      title: Text(MyNetwork.currentChannels[index].name),
                      onTap: () async {
                        MyNetwork.currentChanel =
                            MyNetwork.currentChannels[index];
                        FlutterSecureStorage storage = FlutterSecureStorage();
                        await storage.write(
                            key: "currentChannel", value: index.toString());
                        Navigator.pushNamed(context, '/video');
                      },
                      leading: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          MyNetwork.currentChannels[index].icon,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: const Color(0xff4A4A4A).withOpacity(0.70),
              child: ListView.builder(
                physics: const ClampingScrollPhysics(),
                itemCount: MyNetwork.currectEPG.length,
                controller: ScrollController(),
                itemBuilder: (context, index) {
                  return Material(
                    color: Colors.transparent,
                    child: ListTile(
                      leading: Text(MyNetwork.currectEPG[index].startdt),
                      title: Text(MyNetwork.currectEPG[index].title),
                      subtitle: Text(
                        MyNetwork.currectEPG[index].description,
                        overflow: TextOverflow.fade,
                      ),
                      onTap: () {},
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
