import 'package:flutter/material.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';

class ButtonDetector extends StatefulWidget {
  const ButtonDetector({Key? key}) : super(key: key);

  @override
  _ButtonDetectorState createState() => _ButtonDetectorState();
}

class _ButtonDetectorState extends State<ButtonDetector> {
  void _onKey(RawKeyEvent e) {
    MyPrint.printWarning(e.runtimeType.toString());
    MyPrint.showDiolog(context, e.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RawKeyboardListener(
          autofocus: true,
          focusNode: FocusNode(),
          onKey: _onKey,
          child: Center()),
    );
  }
}
