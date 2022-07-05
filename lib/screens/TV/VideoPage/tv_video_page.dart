import 'package:better_player/better_player.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';
import 'package:odtvprojectfiles/mylibs/myVideoFunctions.dart';
import 'package:odtvprojectfiles/screens/TV/VideoPage/tv_overlay.dart';
import 'package:odtvprojectfiles/screens/TV/VideoPage/tv_video.dart';
import 'package:odtvprojectfiles/screens/TV/VideoPage/tv_video_info.dart';
import 'package:odtvprojectfiles/screens/TV/VideoPage/tv_video_settig.dart';

class TvVideoPage extends StatefulWidget {
  TvVideoPage({Key? key}) : super(key: key);

  @override
  State<TvVideoPage> createState() => _TvVideoPageState();
}

class _TvVideoPageState extends State<TvVideoPage> {
  FocusNode focusNode = FocusNode();
  bool isNumberOverlay = false;
  bool isChannelOverlay = false;

  int numberPressed = 0;
  int timer = 0;
  int channelTime = 0;

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

  void openChannelOverlay() async {
    isChannelOverlay = true;
    setState(() {});
    channelTime++;
    await Future.delayed(Duration(seconds: 3));
    channelTime--;
    if (channelTime <= 0) {
      isChannelOverlay = false;
    }
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
      MyVideoFunctions.currentCategoryofChannelIndex = 1;
      MyVideoFunctions.setVideo();
    }
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  void openDialo() async {
    final value = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Are you sure you want to exit?'),
            actions: <Widget>[
              ElevatedButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              ElevatedButton(
                child: Text('Yes, exit'),
                onPressed: () {
                  FlutterExitApp.exitApp();
                },
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    MyNetwork().getFavorites();
    focusNode = FocusNode(onKey: (node, RawKeyEvent event) {
      if (event.logicalKey == LogicalKeyboardKey.select) {
        try {
          if (event.isKeyPressed(LogicalKeyboardKey.select)) {
            Navigator.of(context).push(
              PageRouteBuilder(
                opaque: false, // set to false
                pageBuilder: (_, __, ___) => TvOverlay(),
              ),
            );
          }
        } catch (e) {
          print(e);
        }
        if (event.physicalKey == PhysicalKeyboardKey.controlRight) {
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false, // set to false
              pageBuilder: (_, __, ___) => TvOverlay(),
            ),
          );
        }
      }

      if (event.runtimeType == RawKeyUpEvent) {
        if (event.logicalKey == LogicalKeyboardKey.contextMenu ||
            event.logicalKey == LogicalKeyboardKey.keyS) {
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false, // set to false
              pageBuilder: (_, __, ___) => TvVideoInfo(),
            ),
          );
        }
      }
      if (event.isKeyPressed(LogicalKeyboardKey.keyA)) {}
      // dsdf
      if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
        int currentChannelIndex = MyNetwork.currentChannels
            .indexWhere((element) => element.id == MyNetwork.currentChanel.id);
        if (currentChannelIndex < (MyNetwork.currentChannels.length - 1)) {
          currentChannelIndex++;
        } else {
          if (MyVideoFunctions.currentCategoryofChannelIndex <
              MyNetwork.categorys.length - 1) {
            MyVideoFunctions.currentCategoryofChannelIndex++;
            setCategory(MyVideoFunctions.currentCategoryofChannelIndex);
            currentChannelIndex = 0;
          }
        }
        MyNetwork.currentChanel =
            MyNetwork.currentChannels[currentChannelIndex];
        MyVideoFunctions.setVideo();
        openChannelOverlay();
        return KeyEventResult.handled;
      }

      if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
        int currentChannelIndex = MyNetwork.currentChannels
            .indexWhere((element) => element.id == MyNetwork.currentChanel.id);
        if (currentChannelIndex > 0) {
          currentChannelIndex--;
        } else {
          if (MyVideoFunctions.currentCategoryofChannelIndex > 0) {
            MyVideoFunctions.currentCategoryofChannelIndex--;
            setCategory(MyVideoFunctions.currentCategoryofChannelIndex);
            print(MyVideoFunctions.currentCategoryofChannelIndex);
            currentChannelIndex = (MyNetwork.currentChannels.length - 1);
          }
        }
        MyNetwork.currentChanel =
            MyNetwork.currentChannels[currentChannelIndex];
        MyVideoFunctions.setVideo();

        openChannelOverlay();
        return KeyEventResult.handled;
      }
      if (event.runtimeType.toString() == 'RawKeyUpEvent' &&
          event.logicalKey == LogicalKeyboardKey.goBack) {
        openDialo();
      }
      if (isNumeric(event.logicalKey.keyLabel) &&
          event.runtimeType.toString() == 'RawKeyDownEvent') {
        MyPrint.printWarning(event.logicalKey.keyLabel);
        changeChanneltoNumber(int.parse(event.logicalKey.keyLabel));
      }
      return KeyEventResult.handled;
    });
  }

  void setCategory(int index) {
    MyVideoFunctions.currentCategoryIndex = index;
    if (MyNetwork.categorys[MyVideoFunctions.currentCategoryIndex].id ==
        "channel") {
      MyNetwork.currentChannels = MyNetwork.channels;
    } else if (MyNetwork.categorys[MyVideoFunctions.currentCategoryIndex].id ==
        "favorites") {
      MyNetwork().getFavorites().then((value) => setState(() {}));
      MyNetwork.currentChannels = MyNetwork.favorites;
    } else {
      MyNetwork.currentChannels = MyNetwork.channels
          .where(((element) =>
              element.category.contains(MyNetwork.categorys[index].id)))
          .toList();
    }
    MyPrint.printWarning(
        MyNetwork.categorys[MyVideoFunctions.currentCategoryIndex].name);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        openDialo();
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                InkWell(
                  autofocus: true,
                  focusNode: focusNode,
                  focusColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        opaque: false, // set to false
                        pageBuilder: (_, __, ___) => TvOverlay(),
                      ),
                    );
                  },
                  child: Container(
                      color: Colors.black, child: Center(child: TvVideo())),
                ),
                isNumberOverlay ? NumberOverLay(context) : SizedBox(),
                isChannelOverlay
                    ? Align(
                        alignment: Alignment.bottomCenter,
                        child: ChannelOverLay(context))
                    : SizedBox(),
              ],
            ),
          ),
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

  EPG getCurrentEPG() {
    for (int i = 0; i < MyNetwork.currectEPG.length; i++) {
      bool temp = DateTime.now().isAfter(MyNetwork.currectEPG[i].startDate) &&
          DateTime.now().isBefore(MyNetwork.currectEPG[i].endDate);

      if (temp) {
        return MyNetwork.currectEPG[i];
      }
    }
    return EPG();
  }

  Widget ChannelOverLay(BuildContext context) {
    return Container(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: FadeInImage.assetNetwork(
              placeholder: "assets/images/page.png",
              image: MyNetwork.currentChanel.icon,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/images/page.png',
                    fit: BoxFit.fitWidth);
              },
            ),
            title: Text((MyNetwork.currentChanel.pos + 1).toString() +
                ". " +
                MyNetwork.currentChanel.name),
            subtitle: Text(getCurrentEPG().title != ""
                ? getCurrentEPG().title
                : "No EPG".tr()),
          ),
        ),
      ),
    );
  }
}
