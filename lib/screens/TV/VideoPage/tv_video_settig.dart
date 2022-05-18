import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';

class TvVideoSetting extends StatefulWidget {
  @override
  State<TvVideoSetting> createState() => _TvVideoSettingState();
}

class _TvVideoSettingState extends State<TvVideoSetting> {
  FocusNode focusNode = FocusNode();

  String getCurrentEPG() {
    for (int i = 0; i < MyNetwork.currectEPG.length; i++) {
      bool temp = DateTime.now().isAfter(MyNetwork.currectEPG[i].startDate) &&
          DateTime.now().isBefore(MyNetwork.currectEPG[i].endDate);

      if (temp) {
        return MyNetwork.currectEPG[i].title;
      }
    }
    return "";
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
    super.initState();
    focusNode = FocusNode(onKey: (node, RawKeyEvent event) {
      if (event.isKeyPressed(LogicalKeyboardKey.keyS) ||
          event.isKeyPressed(LogicalKeyboardKey.contextMenu)) {
        Navigator.pop(context);
      }
      return KeyEventResult.handled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff000000).withOpacity(0.50),
      body: Focus(
        focusNode: focusNode,
        child: Card(
          child: SizedBox(
            width: 400,
            child: Column(
              children: [
                ListTile(
                  leading: FadeInImage.assetNetwork(
                    placeholder: "assets/images/page.png",
                    image: MyNetwork.currentChanel.icon,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset('assets/images/page.png',
                          fit: BoxFit.fitWidth);
                    },
                  ),
                  title: Text(MyNetwork.currentChanel.name),
                  subtitle: Text(getCurrentEPG()),
                  trailing: MyNetwork.currentChanel.isFavorite
                      ? Icon(Icons.favorite)
                      : Icon(Icons.favorite_border_outlined),
                ),
                ListTile(
                  leading: MyNetwork.currentChanel.isFavorite
                      ? Icon(Icons.favorite)
                      : Icon(Icons.favorite_border_outlined),
                  title: Text('Add to facorites'),
                  autofocus: true,
                  onTap: () {
                    addFav(id: MyNetwork.currentChanel.id);

                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
