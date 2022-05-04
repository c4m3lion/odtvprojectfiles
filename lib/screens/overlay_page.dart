import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';
import 'package:odtvprojectfiles/screens/home_page.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class OverlayPage extends StatefulWidget {
  final Function changeVideo;
  OverlayPage(this.changeVideo);

  @override
  State<OverlayPage> createState() => _OvelLayPageState();
}

class _OvelLayPageState extends State<OverlayPage>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  final ItemScrollController itemScrollController = ItemScrollController();
  late AnimationController _drawerSlideController;
  FocusNode focusNodeChannel = new FocusNode();
  FocusNode focusNodeEpg = new FocusNode();
  FocusNode focusNodeCat = new FocusNode();
  late TabController tabController;
  bool tabControllerInitilized = false;

  int currentActiveEPG = 0;
  int currentActiveChannel = 0;

  String searchQuery = "Search query";
  void updateSearchQuery(String newQuery) async {
    if (MyNetwork.categorys[MyLocalData.selectedChannelPage].id == "channel") {
      MyNetwork.currentChannels = MyNetwork.channels;
    } else if (MyNetwork.categorys[MyLocalData.selectedChannelPage].id ==
        "favorites") {
      MyNetwork().getFavorites();
      MyNetwork.currentChannels = MyNetwork.favorites;
    } else {
      MyNetwork.currentChannels = MyNetwork.channels
          .where(((element) => element.category.contains(newQuery)))
          .toList();
    }
    MyPrint.printWarning(
        MyNetwork.categorys[MyLocalData.selectedChannelPage].name);

    currentActiveChannel = _scrollToChannelIndex();

    setState(() {
      searchQuery = newQuery;
    });
    await Future.delayed(Duration(milliseconds: 500));
    if (MyNetwork.currentChannels.length > 0 &&
        currentActiveChannel < MyNetwork.currentChannels.length &&
        currentActiveChannel >= 0) {
      itemScrollController.jumpTo(index: currentActiveChannel);
    }
  }

  bool _isDrawerOpen() {
    return _drawerSlideController.value == 1.0;
  }

  bool _isDrawerOpening() {
    return _drawerSlideController.status == AnimationStatus.forward;
  }

  bool _isDrawerClosed() {
    return _drawerSlideController.value == 0.0;
  }

  void _toggleDrawer() {
    if (_isDrawerOpen() || _isDrawerOpening()) {
      _drawerSlideController.reverse();
    } else {
      _drawerSlideController.forward();
    }
  }

  int _scrollToIndex() {
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

  int _scrollToChannelIndex() {
    for (int i = 0; i < MyNetwork.currentChannels.length; i++) {
      bool temp = MyNetwork.currentChanel.id == MyNetwork.currentChannels[i].id;

      if (temp) {
        currentActiveChannel = i;
        return i;
      }
    }
    currentActiveChannel = 0;

    return 0;
  }

  @override
  void initState() {
    _drawerSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    MyLocalData.isCahnnalPart = false;
    MyLocalData.selectedChannelPage = -1;
    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    _drawerSlideController.dispose();
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent key) async {
        print(key.logicalKey.debugName);
        if (key.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          MyLocalData.isCahnnalPart = true;
          _drawerSlideController.forward();
          FocusScope.of(context).unfocus();
          setState(() {});
          await Future.delayed(Duration(milliseconds: 100));
          FocusScope.of(context).requestFocus(focusNodeCat);
        }
        if (key.isKeyPressed(LogicalKeyboardKey.arrowRight) &&
            MyLocalData.isCahnnalPart) {
          MyLocalData.isCahnnalPart = false;
          _drawerSlideController.reverse();
          setState(() {});
          FocusScope.of(context).requestFocus(focusNodeChannel);
        }
        if (key.isKeyPressed(LogicalKeyboardKey.arrowRight) &&
            !MyLocalData.isCahnnalPart) {
          setState(() {});
          //FocusScope.of(context).requestFocus(focusNodeEpg);
        }
        setState(() {});
      },
      child: Container(
        color: const Color(0xff000000).withOpacity(0.50),
        child: Row(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 180),
              color: const Color(0xff000000).withOpacity(0.50),
              width: MyLocalData.isCahnnalPart ? 180 : 0,
              child: AnimatedBuilder(
                animation: _drawerSlideController,
                builder: (context, child) {
                  return FractionalTranslation(
                    translation:
                        Offset(-1.0 + _drawerSlideController.value, 0.0),
                    child: Container(
                      color: const Color(0xff000000).withOpacity(0.50),
                      width: 180,
                      height: double.infinity,
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
                              focusNode: index == 0 ? focusNodeCat : null,
                              contentPadding: EdgeInsets.all(10),
                              onTap: !MyLocalData.isCahnnalPart
                                  ? null
                                  : () => {
                                        setState(() {
                                          MyLocalData.selectedChannelPage =
                                              index;
                                          MyLocalData.isCahnnalPart = true;
                                          updateSearchQuery(
                                              MyNetwork.categorys[index].id);
                                        }),
                                      },
                              selected:
                                  index == MyLocalData.selectedChannelPage,
                              title: Text(MyNetwork.categorys[index].name),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 180),
              color: const Color(0xff000000).withOpacity(0.50),
              height: double.infinity,
              width: 200,
              child: ScrollablePositionedList.builder(
                initialScrollIndex: _scrollToChannelIndex(),
                itemScrollController: itemScrollController,
                physics: const ClampingScrollPhysics(),
                itemCount: MyNetwork.currentChannels.length,
                itemBuilder: (context, index) {
                  return Material(
                    color: MyNetwork.currentChannels[index].id ==
                            MyNetwork.currentChanel.id
                        ? Colors.cyan.withOpacity(0.4)
                        : Colors.transparent,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10),
                      title: Text(MyNetwork.currentChannels[index].name),
                      autofocus: index == currentActiveChannel,
                      focusNode: index == currentActiveChannel
                          ? focusNodeChannel
                          : null,
                      onTap: () async {
                        MyNetwork.currentChanel =
                            MyNetwork.currentChannels[index];
                        FlutterSecureStorage storage = FlutterSecureStorage();
                        await storage.write(
                            key: "currentChannel",
                            value:
                                MyNetwork.currentChannels[index].id.toString());
                        setState(() {
                          widget.changeVideo();
                        });
                      },
                      leading: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          MyNetwork.currentChannels[index].icon,
                        ),
                      ),
                      selected: MyNetwork.currentChannels[index].id ==
                          MyNetwork.currentChanel.id,
                    ),
                  );
                },
              ),
            ),
            Expanded(child: SizedBox()),
            MyNetwork.currectPageEPG.length > 0
                ? Container(
                    color: const Color(0xff000000).withOpacity(0.50),
                    height: double.infinity,
                    width: 300,
                    child: ScrollablePositionedList.builder(
                        initialScrollIndex: _scrollToIndex(),
                        itemCount: MyNetwork.currectEPG.length,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            height: 80,
                            child: Card(
                              color: currentActiveEPG == index
                                  ? Colors.cyan
                                  : null,
                              child: ListTile(
                                leading:
                                    Text(MyNetwork.currectEPG[index].startdt),
                                title: Text(MyNetwork.currectEPG[index].title),
                              ),
                            ),
                          );
                        }),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
