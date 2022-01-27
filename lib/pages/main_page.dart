// ignore_for_file: prefer_const_constructors

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wakelock/wakelock.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final searchText = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "Search query";
  ////Functions////////////////////
  ///
  ///////////////////////////
  Widget _buildSearchField() {
    return TextField(
      controller: searchText,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Search Data...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.black54),
      ),
      style: TextStyle(color: MyColors.black, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (searchText == null || searchText.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery();
          },
        ),
      ];
    }

    return <Widget>[
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
    ];
  }

  void _startSearch() {
    ModalRoute.of(context)
        ?.addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      searchText.clear();
      updateSearchQuery("");
    });
  }

  @override
  void initState() {
    super.initState();
    Wakelock.disable();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("ODTV"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Channels:",
                    style: TextStyle(color: MyColors.white, fontSize: 30),
                  ),
                  Expanded(child: SizedBox()),
                  RichText(
                    text: TextSpan(
                        text: "see all",
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(context, '/channels');
                          },
                        style: TextStyle(color: MyColors.white, fontSize: 13)),
                  ),
                  InkWell(
                    onTap: () => {
                      Navigator.pushNamed(context, '/channels'),
                    },
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Icon(
                        Icons.arrow_circle_up,
                        size: 20,
                        color: MyColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 150,
              child: ListView.builder(
                physics: ClampingScrollPhysics(),
                itemCount: MyNetwork.channels.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => InkWell(
                  onTap: () => {
                    MyNetwork.isVideoPlaying = true,
                    MyNetwork.currentChanel = MyNetwork.channels[index],
                    Navigator.pushNamed(context, '/video'),
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: MyColors.green,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: FadeInImage.assetNetwork(
                        fit: BoxFit.fill,
                        placeholder:
                            'assets/icons/loadingicon.png', //kTransparentImage,
                        image: MyNetwork.channels[index].icon,
                        imageErrorBuilder: (context, url, error) =>
                            SizedBox(width: 200, child: Icon(Icons.error)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Favorites:",
                    style: TextStyle(color: MyColors.white, fontSize: 30),
                  ),
                  Expanded(child: SizedBox()),
                  RichText(
                    text: TextSpan(
                        text: "see all",
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            MyPrint.printWarning("see all pressed");
                          },
                        style: TextStyle(color: MyColors.white, fontSize: 13)),
                  ),
                  InkWell(
                    onTap: () => {},
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Icon(
                        Icons.arrow_circle_up,
                        size: 20,
                        color: MyColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 150,
              child: ListView.builder(
                physics: ClampingScrollPhysics(),
                itemCount: MyNetwork.channels.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => Card(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: MyColors.green,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25.0),
                    child: FadeInImage.assetNetwork(
                      fit: BoxFit.fill,
                      placeholder:
                          'assets/icons/loadingicon.png', //kTransparentImage,
                      image: MyNetwork.channels[index].icon,
                      imageErrorBuilder: (context, url, error) =>
                          SizedBox(width: 200, child: new Icon(Icons.error)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: MyColors.black,
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 80,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: MyColors.yellow,
                ),
                child: Text(
                  "User: " + MyNetwork.userInfo,
                  style: TextStyle(
                    fontSize: 30,
                    color: MyColors.black,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Card(
                color: MyColors.yellow,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const <Widget>[
                    ListTile(
                      leading: Icon(Icons.tv),
                      title: Text('Channels'),
                    ),
                  ],
                ),
              ),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Card(
                color: MyColors.yellow,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const <Widget>[
                    ListTile(
                      leading: Icon(Icons.favorite),
                      title: Text('Favorites'),
                    ),
                  ],
                ),
              ),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
