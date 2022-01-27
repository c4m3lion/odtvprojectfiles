import 'package:flutter/material.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
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
            if (searchText.text.isEmpty) {
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
    MyNetwork.channelsSeach = MyNetwork.channels
        .where(((element) =>
            element.name.toLowerCase().contains(newQuery.toLowerCase())))
        .toList();
    MyPrint.printWarning(MyNetwork.channelsSeach.length.toString());
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchField(),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 16 / 9,
              crossAxisCount: orientation == Orientation.portrait ? 2 : 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 1,
            ),
            physics: ClampingScrollPhysics(),
            itemCount: MyNetwork.channelsSeach.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) => InkWell(
              onTap: () => {
                MyNetwork.isVideoPlaying = true,
                MyNetwork.currentChanel = MyNetwork.channelsSeach[index],
                Navigator.pushNamed(context, '/video'),
              },
              child: SizedBox(
                height: 10,
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
                      image: MyNetwork.channelsSeach[index].icon,
                      imageErrorBuilder: (context, url, error) =>
                          SizedBox(width: 200, child: Icon(Icons.error)),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
