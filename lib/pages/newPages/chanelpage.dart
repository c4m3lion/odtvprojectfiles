import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';

class ChannelsPage extends StatefulWidget {
  const ChannelsPage({Key? key}) : super(key: key);

  @override
  State<ChannelsPage> createState() => _ChannelsPageState();
}

class _ChannelsPageState extends State<ChannelsPage> {
  String searchQuery = "Search query";
  void updateSearchQuery(String newQuery) {
    if (MyLocalData.selectedCurrentTag == -1) {
      MyLocalData.selectedCurrentTag = 0;
      MyNetwork.currentChannels = MyNetwork.channels;
    } else if (MyNetwork.categorys[MyLocalData.selectedCurrentTag].id ==
        "channel") {
      MyNetwork.currentChannels = MyNetwork.channels;
    } else if (MyNetwork.categorys[MyLocalData.selectedCurrentTag].id ==
        "favorites") {
      MyNetwork.currentChannels = MyNetwork.favorites;
    } else {
      MyNetwork.currentChannels = MyNetwork.channels
          .where(((element) => element.category.contains(newQuery)))
          .toList();
    }
    MyPrint.printWarning(
        MyNetwork.categorys[MyLocalData.selectedCurrentTag].name);
    setState(() {
      searchQuery = newQuery;
    });
  }

  @override
  void initState() {
    updateSearchQuery("");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                  color: index == MyLocalData.selectedCurrentTag
                      ? Colors.cyan.withOpacity(0.4)
                      : Colors.transparent,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10),
                    onTap: () => {
                      setState(() {
                        MyLocalData.selectedCurrentTag = index;
                        updateSearchQuery(MyNetwork.categorys[index].id);
                      }),
                    },
                    selected: index == MyLocalData.selectedCurrentTag,
                    title: Text(MyNetwork.categorys[index].name).tr(),
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          flex: 3,
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
                          key: "currentChannel",
                          value: MyNetwork.currentChannels[index].name);
                      Navigator.pushNamed(context, '/home');
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
      ],
    );
  }
}
