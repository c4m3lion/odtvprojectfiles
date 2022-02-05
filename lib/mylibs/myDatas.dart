import 'package:flutter/material.dart';
import 'package:odtvprojectfiles/mylibs/myNetwork.dart';

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
}

class MyFunctions {
  static Future<void> channelButton(BuildContext context, int index) async {
    MyNetwork.isVideoPlaying = true;
    MyNetwork.currentChanel = MyNetwork.channels[index];
    await Navigator.pushNamed(context, '/loading');
  }

  static Future<void> FavoriteChannelButton(
      BuildContext context, int index) async {
    MyNetwork.isVideoPlaying = true;
    MyNetwork.currentChanel = MyNetwork.favorites[index];
    await Navigator.pushNamed(context, '/loading');
  }
}
