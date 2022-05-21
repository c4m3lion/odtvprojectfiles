import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fraction/fraction.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';
import 'package:odtvprojectfiles/mylibs/myVideoFunctions.dart';
import 'package:odtvprojectfiles/screens/TV/VideoPage/tvsetting/change_aspect_ratio.dart';
import 'package:odtvprojectfiles/screens/TV/VideoPage/tvsetting/change_bitrate.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class TvVideoInfo extends StatefulWidget {
  const TvVideoInfo({Key? key}) : super(key: key);

  @override
  State<TvVideoInfo> createState() => _TvVideoInfoState();
}

class _TvVideoInfoState extends State<TvVideoInfo> {
  FocusNode focusNode = FocusNode();
  EPG currentActiveEPG = EPG();

  EPG getCurrentEPG() {
    for (int i = 0; i < MyNetwork.currectEPG.length; i++) {
      bool temp = DateTime.now().isAfter(MyNetwork.currectEPG[i].startDate) &&
          DateTime.now().isBefore(MyNetwork.currectEPG[i].endDate);

      if (temp) {
        currentActiveEPG = MyNetwork.currectEPG[i];
        return MyNetwork.currectEPG[i];
      }
    }
    currentActiveEPG = EPG();
    return EPG();
  }

  void addFav({required String id}) async {
    setState(() {});
    if (!MyNetwork.currentChanel.isFavorite) {
      MyNetwork.currentChanel.isFavorite = true;
      setState(() {});
      String k = await MyNetwork().addFavorite(channel_id: id);
      if (k == "OK") {
        MyNetwork.currentChanel.isFavorite = true;
      }
    } else {
      MyNetwork.currentChanel.isFavorite = false;
      setState(() {});
      String k = await MyNetwork().removeFavorite(channel_id: id);
      if (k == "OK") {
        MyNetwork.currentChanel.isFavorite = false;
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode(
        canRequestFocus: false,
        onKey: (node, RawKeyEvent event) {
          if (event.isKeyPressed(LogicalKeyboardKey.keyS) ||
              event.isKeyPressed(LogicalKeyboardKey.contextMenu)) {
            Navigator.pop(context);
          }
          if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft) ||
              event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff000000).withOpacity(0.50),
      body: Focus(
        focusNode: focusNode,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      ListTile(
                        leading: FadeInImage.assetNetwork(
                          placeholder: "assets/images/page.png",
                          image: MyNetwork.currentChanel.icon,
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Image.asset('assets/images/page.png',
                                fit: BoxFit.fitWidth);
                          },
                        ),
                        title: Text(
                            (MyNetwork.currentChanel.pos + 1).toString() +
                                ". " +
                                MyNetwork.currentChanel.name),
                        subtitle: Text(getCurrentEPG().title),
                        trailing: MyNetwork.currentChanel.isFavorite
                            ? Icon(Icons.favorite)
                            : Icon(Icons.favorite_border_outlined),
                      ),
                      Text(currentActiveEPG.startdt +
                          " - " +
                          currentActiveEPG.enddt),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          getCurrentEPG().description.toLowerCase(),
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: SizedBox(
                  width: 280,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        autofocus: true,
                        leading: MyNetwork.currentChanel.isFavorite
                            ? Icon(Icons.favorite)
                            : Icon(Icons.favorite_border_outlined),
                        title: Text(MyNetwork.currentChanel.isFavorite
                                ? "Add to Favorites"
                                : "Remove from Favorites")
                            .tr(),
                        onTap: () {
                          addFav(id: MyNetwork.currentChanel.id);

                          setState(() {});
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.aspect_ratio),
                        title: Text("Aspect Ratio").tr(),
                        subtitle: Text(MyVideoFunctions.aspectRatio
                            .toFraction()
                            .toString()),
                        onTap: () {
                          Navigator.of(context)
                              .push(
                                PageRouteBuilder(
                                  opaque: false, // set to false
                                  pageBuilder: (_, __, ___) =>
                                      TvChangeResolution(),
                                ),
                              )
                              .then((value) => setState(() {}));
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.network_check_sharp),
                        title: Text("Bitrate").tr(),
                        subtitle: Text(
                            MyVideoFunctions.bitrate.toFraction().toString() +
                                " MBit/s"),
                        onTap: () {
                          // Navigator.of(context)
                          //     .push(
                          //       PageRouteBuilder(
                          //         opaque: false, // set to false
                          //         pageBuilder: (_, __, ___) =>
                          //             TvChangeBitrate(),
                          //       ),
                          //     )
                          //     .then((value) => setState(() {}));
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.screenshot_monitor_rounded),
                        title: Text("Resolution").tr(),
                        subtitle: Text("1920x1080"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
