import 'package:better_player/better_player.dart';
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

  int numberPressed = 0;
  int timer = 0;

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
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false, // set to false
              pageBuilder: (_, __, ___) => TvOverlay(),
            ),
          );
        }
      }
      if (event.logicalKey == LogicalKeyboardKey.contextMenu) {
        if (event.runtimeType.toString() == 'RawKeyDownEvent') {
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false, // set to false
              pageBuilder: (_, __, ___) => TvVideoInfo(),
            ),
          );
        }
      }
      if (event.logicalKey == LogicalKeyboardKey.keyS) {
        if (event.runtimeType.toString() == 'RawKeyDownEvent') {
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false, // set to false
              pageBuilder: (_, __, ___) => TvVideoInfo(),
            ),
          );
        }
      }
      // if (event.isKeyPressed(LogicalKeyboardKey.keyS) ||
      //     event.isKeyPressed(LogicalKeyboardKey.contextMenu)) {
      //   Navigator.of(context).push(
      //     PageRouteBuilder(
      //       opaque: false, // set to false
      //       pageBuilder: (_, __, ___) => TvVideoInfo(),
      //     ),
      //   );
      // }
      if (event.isKeyPressed(LogicalKeyboardKey.keyA)) {}
      // dsdf
      if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
        int currentChannelIndex = MyNetwork.currentChannels
            .indexWhere((element) => element.id == MyNetwork.currentChanel.id);
        if (currentChannelIndex < (MyNetwork.currentChannels.length - 1)) {
          currentChannelIndex++;
        } else {
          currentChannelIndex = 0;
        }
        MyNetwork.currentChanel =
            MyNetwork.currentChannels[currentChannelIndex];
        MyVideoFunctions.setVideo();
      }

      if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
        int currentChannelIndex = MyNetwork.currentChannels
            .indexWhere((element) => element.id == MyNetwork.currentChanel.id);
        if (currentChannelIndex > 0) {
          currentChannelIndex--;
        } else {
          currentChannelIndex = (MyNetwork.currentChannels.length - 1);
        }
        MyNetwork.currentChanel =
            MyNetwork.currentChannels[currentChannelIndex];
        MyVideoFunctions.setVideo();
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        openDialo();
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          body: Stack(
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
            ],
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
}
