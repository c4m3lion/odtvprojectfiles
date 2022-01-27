// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';

class ChannelListPage extends StatefulWidget {
  const ChannelListPage({Key? key}) : super(key: key);

  @override
  _ChannelListPageState createState() => _ChannelListPageState();
}

class _ChannelListPageState extends State<ChannelListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Channels"),
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
          itemCount: MyNetwork.channels.length,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) => InkWell(
            onTap: () => {
              MyNetwork.isVideoPlaying = true,
              MyNetwork.currentChanel = MyNetwork.channels[index],
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
                    image: MyNetwork.channels[index].icon,
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
