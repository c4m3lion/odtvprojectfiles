import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';

class MyLanguage {
  //static
}

class MyVars {
  bool isRefresh = false;
}

class MyColors {
  static Color yellow = const Color(0xffFFC914);
  static Color black = const Color(0xff2E282A);
  static Color cyan = const Color(0xff17BEBB);
  static Color orange = const Color(0xffE4572E);
  static Color green = const Color(0xff76B041);
  static Color white = Colors.white;
}

class MyPrint {
  static void printWarning(String text) {
    print('\x1B[33m$text\x1B[0m');
  }

  static void printError(String text) {
    print('\x1B[31m$text\x1B[0m');
  }

  static void showDiolog(BuildContext context, String err) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: MyColors.yellow,
          title: const Text('Error'),
          content: Text(err),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void dialog(BuildContext context, String _title, String _content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_title),
          content: Text(_content),
          actions: [
            ElevatedButton(
              autofocus: true,
              child: const Text('Ok'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

class MyPaints {
  static Color selectedColor = Colors.cyan;
}

class MyFunctions {
  final storage = const FlutterSecureStorage();
  static Future<void> searchChannelButton(
      BuildContext context, int index) async {
    MyNetwork.isVideoPlaying = true;
    MyNetwork.currentChanel = MyNetwork.channelsSeach[index];
    MyPrint.printWarning(MyNetwork.currentChanel.name);
    await Navigator.pushNamed(context, '/loading');
  }

  static Future<void> channelButton(BuildContext context, int index) async {
    MyNetwork.isVideoPlaying = true;
    MyNetwork.currentChanel = MyNetwork.channels[index];
    await Navigator.pushNamed(context, '/video');
  }

  static Future<void> favoriteChannelButton(
      BuildContext context, int index) async {
    MyNetwork.isVideoPlaying = true;
    MyNetwork.currentChanel = MyNetwork.favorites[index];
    await Navigator.pushNamed(context, '/loading');
  }

  void saveStorage(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  Future<String> getStorage(String key) async {
    return await storage.read(key: key) ?? "";
  }
}
