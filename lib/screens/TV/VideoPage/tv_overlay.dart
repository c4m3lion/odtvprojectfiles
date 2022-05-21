import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';
import 'package:odtvprojectfiles/mylibs/myVideoFunctions.dart';
import 'package:odtvprojectfiles/pages/newPages/newSettingPage.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:side_navigation/side_navigation.dart';

class TvOverlay extends StatefulWidget {
  const TvOverlay({Key? key}) : super(key: key);

  @override
  State<TvOverlay> createState() => _TvOverlayState();
}

class _TvOverlayState extends State<TvOverlay> {
  var channelScrollController = ItemScrollController();

  int currentActiveEPG = 0;
  int currentActiveCahnnelIndex = 0;

  bool showEPG = false;

  int selectedPageIndex = 0;

  int highLighttedChannel = 0;

  FocusNode catFocus = FocusNode();
  FocusNode categoyFocus = FocusNode();

  FocusNode channelNode = FocusNode();

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
    catFocus = FocusNode();
    MyVideoFunctions.setCategory = categoryChange;
    loadEpgs();
    WidgetsBinding.instance.addPostFrameCallback((_) => jumpToChannel());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    catFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          color: const Color(0xff000000).withOpacity(0.50),
          child: Row(
            children: [
              //category
              Focus(
                canRequestFocus: false,
                onFocusChange: (value) => {
                  if (value)
                    {
                      catFocus.requestFocus(),
                    }
                },
                child: Container(
                  color: Colors.black,
                  width: 60,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        focusNode:
                            selectedPageIndex == 0 ? catFocus : FocusNode(),
                        onFocusChange: (value) => {
                          if (value)
                            {
                              setState(() {
                                selectedPageIndex = 0;
                              })
                            }
                        },
                        onTap: () {
                          setState(() {
                            selectedPageIndex = 0;
                          });
                        },
                        child: SizedBox(
                          height: 30,
                          child: Image.asset(
                            "assets/images/channels-icon.png",
                            color: 0 == selectedPageIndex
                                ? MyPaints.selectedColor
                                : null,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        focusNode:
                            selectedPageIndex == 1 ? catFocus : FocusNode(),
                        onFocusChange: (value) => {
                          if (value)
                            {
                              setState(() {
                                selectedPageIndex = 1;
                              })
                            }
                        },
                        onTap: () {
                          setState(() {
                            selectedPageIndex = 1;
                          });
                        },
                        child: SizedBox(
                          height: 30,
                          child: Image.asset(
                            "assets/images/settings-icon.png",
                            color: 1 == selectedPageIndex
                                ? MyPaints.selectedColor
                                : null,
                          ),
                        ),
                      ),
                      Expanded(child: SizedBox()),
                      InkWell(
                        focusNode:
                            selectedPageIndex == 2 ? catFocus : FocusNode(),
                        onFocusChange: (value) => {
                          if (value)
                            {
                              setState(() {
                                selectedPageIndex = 2;
                              })
                            }
                        },
                        onTap: () {
                          SystemChannels.platform
                              .invokeMethod('SystemNavigator.pop');
                        },
                        child: Container(
                          height: 40,
                          color: Colors.transparent,
                          child: Image.asset(
                            "assets/images/shutdownicon.png",
                            color: 2 == selectedPageIndex
                                ? MyPaints.selectedColor
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              selectedPageIndex == 0
                  ? Expanded(child: buildMainPage())
                  : SizedBox(),
              selectedPageIndex == 1
                  ? Expanded(child: SettingPage())
                  : SizedBox(),
              selectedPageIndex == 2
                  ? Expanded(child: SettingPage())
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMainPage() {
    return Row(
      children: [
        buildCategory(),
        buildChannel(),
        buildEpg(),
      ],
    );
  }

  Widget buildChannel() {
    //Cahnnels
    return Expanded(
      flex: 3,
      child: Focus(
        canRequestFocus: false,
        onKey: (node, event) {
          if (event.isKeyPressed(LogicalKeyboardKey.keyS) ||
              event.isKeyPressed(LogicalKeyboardKey.contextMenu)) {
            addFav(id: MyNetwork.currentChannels[highLighttedChannel].id);
            setState(() {});
          }
          return KeyEventResult.ignored;
        },
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
                  loadEpgs(channel_id: MyNetwork.currentChannels[index].id);
                  highLighttedChannel = index;
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
                      Text(
                        (MyNetwork.currentChannels[index].pos + 1).toString(),
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(
                        width: 10,
                      ),
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
                        style: Theme.of(context).textTheme.headline6,
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
    );
  }

  Widget buildCategory() {
    return Focus(
      canRequestFocus: false,
      onFocusChange: (value) => {
        if (value) categoyFocus.requestFocus(),
      },
      child: SizedBox(
        width: 250,
        child: ScrollablePositionedList.builder(
          physics: const ClampingScrollPhysics(),
          itemCount: MyNetwork.categorys.length,
          scrollDirection: Axis.vertical,
          initialScrollIndex: MyVideoFunctions.currentCategoryIndex,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () => categoryChange(index),
              autofocus:
                  MyVideoFunctions.currentCategoryIndex == index ? true : false,
              focusNode: MyVideoFunctions.currentCategoryIndex == index
                  ? categoyFocus
                  : FocusNode(),
              onFocusChange: (value) {
                if (value) {
                  categoryChange(index);
                }
              },
              child: Container(
                color: MyVideoFunctions.currentCategoryIndex == index
                    ? Colors.amber.withOpacity(0.2)
                    : Colors.transparent,
                height: 70,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      MyNetwork.categorys[index].name,
                      style: Theme.of(context).textTheme.headline5,
                    ).tr(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildEpg() {
    return MyNetwork.currectPageEPG.length > 0
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
                        leading: Text(MyNetwork.currectEPG[index].startdt),
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
          );
  }
}
