import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/screens/Phone/VideoPage/phone_epg_info.dart';
import 'package:odtvprojectfiles/screens/Phone/VideoPage/phone_video.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../mylibs/myNetwork.dart';
import '../../../mylibs/myVideoFunctions.dart';

class PhoneVideoPlayer extends StatefulWidget {
  const PhoneVideoPlayer({Key? key}) : super(key: key);

  @override
  State<PhoneVideoPlayer> createState() => _PhoneVideoPlayerState();
}

class _PhoneVideoPlayerState extends State<PhoneVideoPlayer> {
  var channelScrollController = ItemScrollController();

  int currentActiveEPG = 0;

  void loadEpgs({String channel_id = "none"}) async {
    channel_id == "none" ? channel_id = MyNetwork.currentChanel.id : null;
    MyNetwork.currectEPG.clear();
    MyNetwork.currectPageEPG.clear();
    setState(() {});
    await MyNetwork().getEPG(channel_id: channel_id);
    setState(() {});
  }

  int jumpToEpg() {
    for (int i = 0; i < MyNetwork.currectEPG.length; i++) {
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
    // TODO: implement initState
    super.initState();
    loadEpgs();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth > 600) {
              return buildRow();
            } else {
              return buildColumn();
            }
          },
        ),
      ),
    );
  }

  Widget buildColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          color: Colors.black,
          child: Stack(
            children: [
              PhoneVideo(),
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
        ListTile(
          leading: FadeInImage.assetNetwork(
            placeholder: "assets/images/page.png",
            image: MyNetwork.currentChanel.icon,
            imageErrorBuilder: (context, error, stackTrace) {
              return Image.asset('assets/images/page.png',
                  fit: BoxFit.fitWidth);
            },
          ),
          title: Text(MyNetwork.currentChanel.name),
          trailing: InkWell(
            onTap: () {
              addFav(id: MyNetwork.currentChanel.id);
            },
            child: MyNetwork.currentChanel.isFavorite
                ? Icon(Icons.favorite)
                : Icon(Icons.favorite_border_outlined),
          ),
        ),
        Divider(),
        Expanded(
          child: buildEPG(),
        ),
      ],
    );
  }

  Widget buildRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Container(
            height: double.infinity,
            child: Column(
              children: [
                Stack(
                  children: [
                    PhoneVideo(),
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back),
                          color: Colors.white),
                    ),
                  ],
                ),
                Expanded(
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
                    trailing: InkWell(
                      onTap: () {
                        addFav(id: MyNetwork.currentChanel.id);
                      },
                      child: MyNetwork.currentChanel.isFavorite
                          ? Icon(Icons.favorite)
                          : Icon(Icons.favorite_border_outlined),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: buildEPG(),
        ),
      ],
    );
  }

  Widget buildEPG() {
    print(MyNetwork.currectEPG.length);
    return MyNetwork.currectEPG.length > 0
        ? Container(
            height: double.infinity,
            child: ScrollablePositionedList.builder(
                initialScrollIndex: jumpToEpg(),
                physics: ClampingScrollPhysics(),
                itemCount: MyNetwork.currectEPG.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(MyNetwork.currectEPG[index].title),
                              content: SingleChildScrollView(
                                  child: Text(
                                      MyNetwork.currectEPG[index].description)),
                            );
                          });
                    },
                    child: SizedBox(
                      height: 80,
                      child: Card(
                        color: currentActiveEPG == index ? Colors.cyan : null,
                        child: ListTile(
                          leading: Text(MyNetwork.currectEPG[index].startdt),
                          title: Text(
                            MyNetwork.currectEPG[index].title,
                            overflow: TextOverflow.fade,
                          ),
                          trailing: Text(MyNetwork.currectEPG[index].enddt),
                        ),
                      ),
                    ),
                  );
                }),
          )
        : const SizedBox(
            width: 280,
            child: Center(
              child: Text("NO EPG!"),
            ),
          );
  }
}
