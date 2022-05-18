import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';
import 'package:odtvprojectfiles/mylibs/myVideoFunctions.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class TvOverlay extends StatefulWidget {
  const TvOverlay({Key? key}) : super(key: key);

  @override
  State<TvOverlay> createState() => _TvOverlayState();
}

class _TvOverlayState extends State<TvOverlay> {
  var channelScrollController = ItemScrollController();

  int currentActiveEPG = 0;
  int currentActiveCahnnelIndex = 0;

  void channelChange(int index) {
    print(MyNetwork.currentChannels[index].name);
    MyNetwork.currentChanel = MyNetwork.currentChannels[index];
    MyNetwork().getEPG();
    setState(() {
      MyVideoFunctions.setVideo();
    });
  }

  void categoryChange(int index) async {
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
    WidgetsBinding.instance.addPostFrameCallback((_) => jumpToChannel());
    setState(() {});
  }

  void jumpToChannel() {
    for (int i = 0; i < MyNetwork.currentChannels.length; i++) {
      if (MyNetwork.currentChanel.id == MyNetwork.currentChannels[i].id) {
        currentActiveCahnnelIndex = i;
        channelScrollController.jumpTo(index: currentActiveCahnnelIndex);
        return;
      }
    }
    if (MyNetwork.currentChannels.length > 0) {
      channelScrollController.jumpTo(index: 0);
    }
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

  void loadEpgs({String channel_id = "none"}) async {
    channel_id == "none" ? channel_id = MyNetwork.currentChanel.id : null;
    MyNetwork.currectEPG.clear();
    MyNetwork.currectPageEPG.clear();
    setState(() {});
    await MyNetwork().getEPG(channel_id: channel_id);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    MyVideoFunctions.setCategory = categoryChange;
    loadEpgs();
    WidgetsBinding.instance.addPostFrameCallback((_) => jumpToChannel());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: const Color(0xff000000).withOpacity(0.50),
        child: Row(
          children: [
            //category
            SizedBox(
              width: 250,
              child: ListView.builder(
                physics: const ClampingScrollPhysics(),
                itemCount: MyNetwork.categorys.length,
                scrollDirection: Axis.vertical,
                controller: ScrollController(),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => categoryChange(index),
                    autofocus: MyVideoFunctions.currentCategoryIndex == index
                        ? true
                        : false,
                    onFocusChange: (value) {
                      if (value) {
                        categoryChange(index);
                      }
                    },
                    child: SizedBox(
                      height: 70,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            MyNetwork.categorys[index].name,
                            style: Theme.of(context).textTheme.headline4,
                          ).tr(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            //Cahnnels
            Expanded(
              flex: 3,
              child: ScrollablePositionedList.builder(
                itemScrollController: channelScrollController,
                physics: const ClampingScrollPhysics(),
                itemCount: MyNetwork.currentChannels.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => channelChange(index),
                    onFocusChange: (value) {
                      if (value) {
                        loadEpgs(
                            channel_id: MyNetwork.currentChannels[index].id);
                      }
                    },
                    autofocus: MyNetwork.currentChanel.id ==
                            MyNetwork.currentChannels[index].id
                        ? true
                        : false,
                    child: Container(
                      height: 70,
                      color: MyNetwork.currentChanel.id ==
                              MyNetwork.currentChannels[index].id
                          ? Colors.orange.withOpacity(0.2)
                          : Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                MyNetwork.currentChannels[index].icon,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              MyNetwork.currentChannels[index].name,
                              style: Theme.of(context).textTheme.headline5,
                            ),
                            Expanded(child: SizedBox()),
                            MyNetwork.currentChannels[index].isFavorite
                                ? Icon(Icons.favorite)
                                : Icon(Icons.favorite_border_outlined),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            MyNetwork.currectPageEPG.length > 0
                ? Container(
                    height: double.infinity,
                    width: 280,
                    child: ScrollablePositionedList.builder(
                        initialScrollIndex: jumpToEpg(),
                        itemCount: MyNetwork.currectEPG.length,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            height: 80,
                            child: Card(
                              color: currentActiveEPG == index
                                  ? Colors.cyan
                                  : Colors.black.withOpacity(0.5),
                              child: ListTile(
                                leading:
                                    Text(MyNetwork.currectEPG[index].startdt),
                                title: Text(
                                  MyNetwork.currectEPG[index].title,
                                  overflow: TextOverflow.fade,
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
                  ),
          ],
        ),
      ),
    );
  }
}
