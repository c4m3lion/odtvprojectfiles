import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fraction/fraction.dart';
import 'package:odtvprojectfiles/mylibs/myVideoFunctions.dart';

class TvChangeBitrate extends StatefulWidget {
  const TvChangeBitrate({Key? key}) : super(key: key);

  @override
  State<TvChangeBitrate> createState() => _TvChangeBitrateState();
}

class _TvChangeBitrateState extends State<TvChangeBitrate> {
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode(onKey: (node, RawKeyEvent event) {
      if (event.isKeyPressed(LogicalKeyboardKey.keyS) ||
          event.isKeyPressed(LogicalKeyboardKey.contextMenu)) {
        Navigator.pop(context);
      }
      return KeyEventResult.ignored;
    });
  }

  handleKey(RawKeyEvent key) {
    if (key.isKeyPressed(LogicalKeyboardKey.keyS) ||
        key.isKeyPressed(LogicalKeyboardKey.contextMenu)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(canRequestFocus: false),
      onKey: handleKey,
      child: Scaffold(
        backgroundColor: const Color(0xff000000).withOpacity(0.50),
        body: Center(
          child: Card(
            child: SizedBox(
              width: 280,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text("Auto"),
                    autofocus: true,
                    onTap: () {
                      MyVideoFunctions.changeBitrate(4.0);
                      setState(() {});
                    },
                  ),
                  ListTile(
                    title: Text("4 MBit/s"),
                    onTap: () {
                      MyVideoFunctions.changeBitrate(4.0);
                      setState(() {});
                    },
                  ),
                  ListTile(
                    title: Text("2 MBit/s"),
                    onTap: () {
                      MyVideoFunctions.changeBitrate(2.0);
                      setState(() {});
                    },
                  ),
                  ListTile(
                    title: Text("1 MBit/s"),
                    onTap: () {
                      MyVideoFunctions.changeBitrate(1.0);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
