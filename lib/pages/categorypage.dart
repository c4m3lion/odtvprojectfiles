import 'package:flutter/material.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String searchQuery = "Search query";
  void updateSearchQuery(String newQuery) {
    MyNetwork.channelsSeach = MyNetwork.channels
        .where(((element) => element.category.contains(newQuery)))
        .toList();
    MyPrint.printWarning(MyNetwork.channelsSeach.length.toString());
    setState(() {
      searchQuery = newQuery;
    });
  }

  @override
  void initState() {
    updateSearchQuery(MyNetwork.catId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(MyNetwork.categroyName),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return ListView.builder(
            physics: ClampingScrollPhysics(),
            itemCount: MyNetwork.channelsSeach.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) => InkWell(
              onTap: () => {MyFunctions.searchChannelButton(context, index)},
              child: SizedBox(
                height: 80,
                child: Card(
                  child: Row(
                    children: [
                      ClipOval(
                        child: Image.network(
                          MyNetwork.channelsSeach[index].icon,
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
                      Text(MyNetwork.channelsSeach[index].name),
                    ],
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
