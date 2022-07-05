import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
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
  List<FocusNode> categoryFocus = List<FocusNode>.generate(
      MyNetwork.categorys.length, (int index) => FocusNode());

  List<FocusNode> channelFocus = List<FocusNode>.generate(
      MyNetwork.currentChannels.length, (int index) => FocusNode());

  FocusNode curChannelFocus = FocusNode();

  bool exculudeSidebar = true;
  bool exculdeCategory = true;
  bool exculdeChannel = false;
  bool exculdeSetting = true;

  void channelChange(int index) {
    MyVideoFunctions.currentCategoryofChannelIndex =
        MyVideoFunctions.currentCategoryIndex;
    print(MyNetwork.currentChannels[index].name);
    MyNetwork.currentChanel = MyNetwork.currentChannels[index];
    MyNetwork().getEPG().then(
        (value) => loadEpgs(channel_id: MyNetwork.currentChannels[index].id));
    setState(() {
      MyVideoFunctions.setVideo();
    });
  }

  void categoryChange(int index) {
    MyVideoFunctions.currentCategoryIndex = index;
    MyVideoFunctions.currentCategoryofChannelIndex = index;
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
    channelFocus = List<FocusNode>.generate(
        MyNetwork.currentChannels.length, (int index) => FocusNode());
    MyPrint.printWarning(
        MyNetwork.categorys[MyVideoFunctions.currentCategoryIndex].name);
    WidgetsBinding.instance.addPostFrameCallback((_) => jumpToChannel());

    setState(() {});
    MyPrint.printError(
        MyVideoFunctions.currentCategoryofChannelIndex.toString());
  }

  void jumpToChannel() {
    for (int i = 0; i < MyNetwork.currentChannels.length; i++) {
      if (MyNetwork.currentChanel.id == MyNetwork.currentChannels[i].id) {
        currentActiveCahnnelIndex = i;
        channelScrollController.jumpTo(index: currentActiveCahnnelIndex);
        setState(() {});
        return;
      }
    }
    if (MyNetwork.currentChannels.length > 0) {
      channelScrollController.jumpTo(index: 0);
    }
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
    if (!MyNetwork.currentChannels[highLighttedChannel].isFavorite) {
      MyNetwork.currentChannels[highLighttedChannel].isFavorite = true;
      setState(() {});
      String k = await MyNetwork().addFavorite(channel_id: id);
      if (k == "OK") {
        MyNetwork.currentChannels[highLighttedChannel].isFavorite = true;
      }
    } else {
      MyNetwork.currentChannels[highLighttedChannel].isFavorite = false;
      setState(() {});
      String k = await MyNetwork().removeFavorite(channel_id: id);
      if (k == "OK") {
        MyNetwork.currentChannels[highLighttedChannel].isFavorite = false;
      }
    }
    setState(() {});
  }

  void addFavHighlighted() {
    print(highLighttedChannel);
    addFav(id: MyNetwork.currentChannels[highLighttedChannel].id);
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
    // TODO: implement initState
    super.initState();
    catFocus = FocusNode();
    MyVideoFunctions.setCategory = categoryChange;
    exculdeChannel = false;
    setState(() {});
    loadEpgs();
    categoryChange(MyVideoFunctions.currentCategoryofChannelIndex);
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
              ExcludeFocus(
                excluding: exculudeSidebar,
                child: Focus(
                  canRequestFocus: false,
                  onKey: (node, event) {
                    if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
                      exculdeChannel = true;
                      selectedPageIndex == 0
                          ? exculdeCategory = false
                          : exculdeCategory = true;
                      selectedPageIndex == 1
                          ? exculdeSetting = false
                          : exculdeSetting = true;

                      exculudeSidebar = true;
                      setState(() {});

                      WidgetsBinding.instance.addPostFrameCallback(
                          (_) => FocusScope.of(context).nextFocus());

                      WidgetsBinding.instance.addPostFrameCallback((_) =>
                          categoryFocus[MyVideoFunctions.currentCategoryIndex]
                              .requestFocus());
                      return KeyEventResult.handled;
                    }
                    if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    width: 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        IconButton(
                          focusColor: Colors.amber,
                          splashRadius: 50,
                          iconSize: 100,
                          onPressed: () {
                            setState(() {
                              selectedPageIndex = 0;
                            });
                          },
                          icon: Image.asset(
                            "assets/images/channels-icon.png",
                            color: 0 == selectedPageIndex
                                ? MyPaints.selectedColor
                                : null,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        IconButton(
                          focusColor: Colors.amber,
                          splashRadius: 50,
                          iconSize: 100,
                          onPressed: () {
                            setState(() {
                              selectedPageIndex = 1;
                            });
                          },
                          icon: Image.asset(
                            "assets/images/settings-icon.png",
                            color: 1 == selectedPageIndex
                                ? MyPaints.selectedColor
                                : null,
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        IconButton(
                          focusColor: Colors.amber,
                          splashRadius: 50,
                          iconSize: 100,
                          onPressed: () {
                            openDialo();
                          },
                          icon: Image.asset(
                            "assets/images/shutdownicon.png",
                            color: 2 == selectedPageIndex
                                ? MyPaints.selectedColor
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              selectedPageIndex == 0
                  ? Expanded(child: buildMainPage())
                  : SizedBox(),
              selectedPageIndex == 2 || selectedPageIndex == 1
                  ? Expanded(
                      child: ExcludeFocus(
                          excluding: exculdeSetting,
                          child: Focus(
                              canRequestFocus: false,
                              onKey: (node, event) {
                                if (event.runtimeType == RawKeyUpEvent) {
                                  if (event.logicalKey ==
                                      LogicalKeyboardKey.arrowRight) {
                                    return KeyEventResult.handled;
                                  }
                                  if (event.logicalKey ==
                                      LogicalKeyboardKey.arrowLeft) {
                                    exculdeChannel = true;
                                    exculdeCategory = true;
                                    exculudeSidebar = false;
                                    exculdeSetting = true;
                                    setState(() {});

                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) =>
                                            FocusScope.of(context).nextFocus());
                                    return KeyEventResult.handled;
                                  }
                                }

                                return KeyEventResult.ignored;
                              },
                              child: SettingPage())),
                    )
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
      child: ExcludeFocus(
        excluding: exculdeChannel,
        child: Focus(
          canRequestFocus: MyNetwork.currentChannels.length > 0 ? false : true,
          onKey: (node, event) {
            if (event.runtimeType == RawKeyUpEvent) {
              if (event.logicalKey == LogicalKeyboardKey.contextMenu ||
                  event.logicalKey == LogicalKeyboardKey.keyS) {
                addFavHighlighted();
                setState(() {});
              }
            }
            if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
              return KeyEventResult.handled;
            }
            if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
              exculdeCategory = false;
              exculdeChannel = true;
              exculudeSidebar = true;
              setState(() {});
              WidgetsBinding.instance.addPostFrameCallback((_) =>
                  categoryFocus[MyVideoFunctions.currentCategoryIndex]
                      .requestFocus());

              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: ScrollablePositionedList.builder(
            itemScrollController: channelScrollController,
            physics: const ClampingScrollPhysics(),
            itemCount: MyNetwork.currentChannels.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              if (MyNetwork.currentChanel.id ==
                      MyNetwork.currentChannels[index].id ||
                  index == 0) {
                curChannelFocus = channelFocus[index];
              }
              return Focus(
                canRequestFocus: false,
                onKey: (node, event) {
                  if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) &&
                      index == MyNetwork.currentChannels.length - 1) {
                    if (MyVideoFunctions.currentCategoryofChannelIndex <
                            MyNetwork.categorys.length - 1 &&
                        MyVideoFunctions.currentCategoryIndex != 0) {
                      MyVideoFunctions.currentCategoryofChannelIndex++;
                      categoryChange(
                          MyVideoFunctions.currentCategoryofChannelIndex);
                      MyPrint.printError(MyVideoFunctions
                          .currentCategoryofChannelIndex
                          .toString());
                      setState(() {});
                      WidgetsBinding.instance.addPostFrameCallback((_) =>
                          FocusScope.of(context).requestFocus(channelFocus[0]));

                      Future.delayed(const Duration(milliseconds: 300), () {
                        channelScrollController.jumpTo(index: 0);
                        setState(() {});
                      });
                      return KeyEventResult.handled;
                    }
                    if (MyVideoFunctions.currentCategoryIndex == 0) {
                      FocusScope.of(context).requestFocus(channelFocus[0]);
                      Future.delayed(const Duration(milliseconds: 300), () {
                        channelScrollController.jumpTo(index: 0);
                        setState(() {});
                      });
                      return KeyEventResult.handled;
                    }
                  }
                  if (event.isKeyPressed(LogicalKeyboardKey.arrowUp) &&
                      index == 0) {
                    if (MyVideoFunctions.currentCategoryofChannelIndex > 0 &&
                        MyVideoFunctions.currentCategoryIndex != 0) {
                      MyVideoFunctions.currentCategoryofChannelIndex--;
                      categoryChange(
                          MyVideoFunctions.currentCategoryofChannelIndex);
                      MyPrint.printError(MyVideoFunctions
                          .currentCategoryofChannelIndex
                          .toString());
                      setState(() {});
                      WidgetsBinding.instance.addPostFrameCallback((_) =>
                          FocusScope.of(context).requestFocus(
                              channelFocus[channelFocus.length - 1]));
                      Future.delayed(const Duration(milliseconds: 300), () {
                        channelScrollController.jumpTo(
                            index: channelFocus.length - 1);
                        setState(() {});
                      });
                      return KeyEventResult.handled;
                    }
                    if (MyVideoFunctions.currentCategoryIndex == 0) {
                      FocusScope.of(context)
                          .requestFocus(channelFocus[channelFocus.length - 1]);

                      Future.delayed(const Duration(milliseconds: 300), () {
                        channelScrollController.jumpTo(
                            index: channelFocus.length - 1);
                        setState(() {});
                      });
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
                child: InkWell(
                  onTap: () => channelChange(index),
                  onFocusChange: (value) {
                    if (value) {
                      loadEpgs(channel_id: MyNetwork.currentChannels[index].id);
                      highLighttedChannel = index;
                      setState(() {});
                    }
                  },
                  focusNode: channelFocus[index],
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
                            (MyNetwork.currentChannels[index].pos + 1)
                                .toString(),
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildCategory() {
    return ExcludeFocus(
      excluding: exculdeCategory,
      child: Focus(
        canRequestFocus: false,
        onKey: (node, event) {
          print(event.data.logicalKey);
          if (event.runtimeType == RawKeyUpEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              exculdeChannel = false;
              exculdeCategory = true;

              exculudeSidebar = true;
              setState(() {});
              WidgetsBinding.instance.addPostFrameCallback(
                  (_) => FocusScope.of(context).requestFocus(curChannelFocus));

              return KeyEventResult.handled;
            }
          }
          if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
            exculdeChannel = true;
            exculdeCategory = true;
            exculudeSidebar = false;
            setState(() {});

            WidgetsBinding.instance.addPostFrameCallback(
                (_) => FocusScope.of(context).nextFocus());
            WidgetsBinding.instance
                .addPostFrameCallback((_) => catFocus.requestFocus());

            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: SizedBox(
          width: 250,
          child: ScrollablePositionedList.builder(
            physics: const ClampingScrollPhysics(),
            itemCount: MyNetwork.categorys.length,
            scrollDirection: Axis.vertical,
            initialScrollIndex: MyVideoFunctions.currentCategoryIndex,
            itemBuilder: (context, index) {
              return Focus(
                canRequestFocus: false,
                onFocusChange: (value) {
                  if (value) {
                    categoryChange(index);
                  }
                },
                child: InkWell(
                  onTap: () => categoryChange(index),
                  focusNode: categoryFocus[index],
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
                ),
              );
            },
          ),
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
        : SizedBox(
            width: 280,
            child: Center(
              child: Text("No EPG").tr(),
            ),
          );
  }
}
