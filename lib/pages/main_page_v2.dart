// ignore_for_file: prefer_const_constructors

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';
import 'package:wakelock/wakelock.dart';

class MainPagev2 extends StatefulWidget {
  const MainPagev2({Key? key}) : super(key: key);

  @override
  _MainPagev2State createState() => _MainPagev2State();
}

class _MainPagev2State extends State<MainPagev2> {
  final searchText = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "Search query";

  void handleClick(String value) {
    switch (value) {
      case 'Settings':
        //TODO: add setting menu here
        MyPrint.printWarning("Setting Menu Oppend");
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
  }

  void callBack() {
    setState(() {});
  }

  @override
  void initState() {
    MyPrint.printError("ISLEYIR");
    super.initState();
    Wakelock.disable();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("ODTV"),
          actions: [
            PopupMenuButton<String>(
              onSelected: handleClick,
              itemBuilder: (BuildContext context) {
                return {'Settings'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice).tr(),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: ListView.builder(
            physics: ClampingScrollPhysics(),
            itemCount: MyNetwork.channels.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) => InkWell(
              onTap: () async => {
                await MyFunctions.channelButton(context, index),
                setState(() {}),
              },
              child: SizedBox(
                height: 70,
                child: Card(
                  child: Row(
                    children: [
                      ClipOval(
                        child: Image.network(
                          MyNetwork.channels[index].icon,
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            // Appropriate logging or analytics, e.g.
                            // myAnalytics.recordError(
                            //   'An error occurred loading "https://example.does.not.exist/image.jpg"',
                            //   exception,
                            //   stackTrace,
                            // );
                            return const Text('ð¢');
                          },
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(MyNetwork.channels[index].name),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              InkWell(
                onTap: () async => {
                  MyNetwork.catId = "",
                  MyNetwork.categroyName = "",
                  Navigator.pushNamed(context, '/category'),
                  setState(() {}),
                },
                child: SizedBox(
                  height: 70,
                  child: Card(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Text('Channels').tr(),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () async => {
                  Navigator.pushNamed(context, '/favorite'),
                },
                child: SizedBox(
                  height: 70,
                  child: Card(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Text('Favorites').tr()
                      ],
                    ),
                  ),
                ),
              ),
              ListView.builder(
                physics: ClampingScrollPhysics(),
                itemCount: MyNetwork.categorys.length,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) => InkWell(
                  onTap: () async => {
                    MyNetwork.catId = MyNetwork.categorys[index].id,
                    MyNetwork.categroyName = MyNetwork.categorys[index].name,
                    Navigator.pushNamed(context, '/category'),
                    setState(() {}),
                  },
                  child: SizedBox(
                    height: 70,
                    child: Card(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text(MyNetwork.categorys[index].name.tr()),
                        ],
                      ),
                    ),
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
