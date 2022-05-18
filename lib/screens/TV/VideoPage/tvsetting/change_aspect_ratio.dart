import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fraction/fraction.dart';
import 'package:odtvprojectfiles/mylibs/myVideoFunctions.dart';

class TvChangeResolution extends StatefulWidget {
  const TvChangeResolution({Key? key}) : super(key: key);

  @override
  State<TvChangeResolution> createState() => _TvChangeResolutionState();
}

class _TvChangeResolutionState extends State<TvChangeResolution> {
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
                      MyVideoFunctions.changeAspectRatio(
                          "16/9".toFraction().toDouble());
                      setState(() {});
                    },
                  ),
                  ListTile(
                    title: Text("16:9"),
                    onTap: () {
                      MyVideoFunctions.changeAspectRatio(
                          "16/9".toFraction().toDouble());
                      setState(() {});
                    },
                  ),
                  ListTile(
                    title: Text("4:3"),
                    onTap: () {
                      MyVideoFunctions.changeAspectRatio(
                          "4/3".toFraction().toDouble());
                      setState(() {});
                    },
                  ),
                  ListTile(
                    title: Text("1:1"),
                    onTap: () {
                      MyVideoFunctions.changeAspectRatio(
                          "1/1".toFraction().toDouble());
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
