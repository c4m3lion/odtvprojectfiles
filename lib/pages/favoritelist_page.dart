// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';

class FavoriteListPage extends StatefulWidget {
  const FavoriteListPage({Key? key}) : super(key: key);

  @override
  _FavoriteListPageState createState() => _FavoriteListPageState();
}

class _FavoriteListPageState extends State<FavoriteListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorites"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
        ],
      ),
      body: OrientationBuilder(builder: (context, orientation) {
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 16 / 9,
            crossAxisCount: orientation == Orientation.portrait ? 2 : 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 1,
          ),
          physics: ClampingScrollPhysics(),
          itemCount: MyNetwork.favorites.length,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) => InkWell(
            onTap: () => {MyFunctions.favoriteChannelButton(context, index)},
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
                    image: MyNetwork.favorites[index].icon,
                    imageErrorBuilder: (context, url, error) =>
                        SizedBox(width: 200, child: Icon(Icons.error)),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
