import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';

class MyNetwork {
  FlutterSecureStorage storage = FlutterSecureStorage();
  static String token = "";
  static String userInfo = "";
  static Channel currentChanel = Channel();
  static List<EPG> currectEPG = List.empty(growable: true);
  static List<Channel> channels = List.empty(growable: true);
  static List<Channel> currentChannels = List.empty(growable: true);
  static List<Category> categorys = List.empty(growable: true);
  static List<Channel> channelsSeach = List.empty(growable: true);
  static List<Channel> favorites = List.empty(growable: true);
  static bool isVideoPlaying = false;
  static StreamController<int> favController = StreamController<int>();
  static String catId = "";
  static String categroyName = "";

  Future<String> login({required String login, required String pass}) async {
    try {
      String macAdress = "02:00:00:00:00:00";
      userInfo = login;
      Response response = await post(
        Uri.parse("https://mw.odtv.az/api/v1/auth"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          {
            "login": login,
            "password": pass,
            "mac": macAdress,
          },
        ),
      );
      MyPrint.printWarning(response.body);
      Map data = jsonDecode(response.body);
      if (data.containsKey("error")) {
        return data['error']['message'];
      } else {
        token = data['sid'];
        return "OK";
      }
    } catch (e) {
      MyPrint.printError(e.toString());
      return e.toString();
    }
  }

  Future<String> getChannels() async {
    try {
      Response response = await get(
        Uri.parse("https://mw.odtv.az/api/v1/channels"),
        headers: {
          'oms-client': token,
        },
      );
      MyPrint.printWarning(response.body);
      Map data = jsonDecode(response.body);
      if (data.containsKey("error")) {
        return data['error']['message'];
      } else {
        categorys.clear();
        channels.clear();
        Category c1 = Category();
        c1.id = "favorites";
        c1.position = -1;
        c1.name = "Favorites";
        categorys.add(c1);
        c1 = Category();
        c1.id = "channel";
        c1.position = -2;
        c1.name = "Channels";
        categorys.add(c1);
        for (var i in data['categories']) {
          Category c = Category();
          c.id = i['id'];
          c.position = i['position'];
          c.name = i['name'];
          categorys.add(c);
        }
        int l = 0;
        for (var i in data['channels']) {
          Channel c = Channel();
          c.id = i['id'];
          c.lcn = i['lcn'];
          c.position = i['position'];
          c.name = i['name'];
          c.category = i['category'];
          c.archive = i['archive'];
          c.icon = i['icon'];
          c.pos = l;
          l++;
          channels.add(c);
        }
        channels.sort((a, b) => a.position.compareTo(b.position));
        for (var i in channels) {
          print(i.name + " " + i.lcn.toString());
        }
        currentChanel = channels[0];
        currentChannels = channels;
        return "OK";
      }
    } catch (e) {
      MyPrint.printError(e.toString());
      return e.toString();
    }
  }

  Future<String> getFavorites() async {
    try {
      Response response = await get(
        Uri.parse("https://mw.odtv.az/api/v1/channel_fav"),
        headers: {
          'oms-client': token,
        },
      );
      MyPrint.printWarning(response.body);
      Map data = jsonDecode(response.body);
      if (data.containsKey("error")) {
        return data['error']['message'];
      } else {
        updateFavorites(data);
        return "OK";
      }
    } catch (e) {
      MyPrint.printError(e.toString());
      return e.toString();
    }
  }

  Future<String> addFavorite({String channel_id = "none"}) async {
    channel_id == "none" ? channel_id = currentChanel.id : null;
    try {
      Response response = await post(
        Uri.parse("https://mw.odtv.az/api/v1/channel_fav/add/$channel_id"),
        headers: {
          'oms-client': token,
        },
      );
      MyPrint.printWarning(response.body);
      Map data = jsonDecode(response.body);
      if (data.containsKey("error")) {
        return data['error']['message'];
      } else {
        updateFavorites(data);
        return "OK";
      }
    } catch (e) {
      MyPrint.printError(e.toString());
      return e.toString();
    }
  }

  Future<String> removeFavorite({String channel_id = "none"}) async {
    channel_id == "none" ? channel_id = currentChanel.id : null;
    try {
      Response response = await post(
        Uri.parse("https://mw.odtv.az/api/v1/channel_fav/remove/$channel_id"),
        headers: {
          'oms-client': token,
        },
      );
      MyPrint.printWarning(response.body);
      Map data = jsonDecode(response.body);
      if (data.containsKey("error")) {
        return data['error']['message'];
      } else {
        updateFavorites(data);
        return "OK";
      }
    } catch (e) {
      MyPrint.printError(e.toString());
      return e.toString();
    }
  }

  // ignore: non_constant_identifier_names
  Future<String> getPlayBack({String channel_id = "none"}) async {
    channel_id == "none" ? channel_id = currentChanel.id : null;
    try {
      Response response = await get(
        Uri.parse("https://mw.odtv.az/api/v1/channel_url/$channel_id"),
        headers: {
          'oms-client': token,
        },
      );
      MyPrint.printWarning(response.body);
      Map data = jsonDecode(response.body);
      if (data.containsKey("error")) {
        return data['error']['message'];
      } else {
        return data['url'];
      }
    } catch (e) {
      MyPrint.printError(e.toString());
      return e.toString();
    }
  }

  Future<String> getEPG({String channel_id = "none"}) async {
    channel_id == "none" ? channel_id = currentChanel.id : null;
    currectEPG.clear();
    try {
      Response response = await get(
        Uri.parse("https://mw.odtv.az/api/v1/epg/$channel_id"),
        headers: {
          'oms-client': token,
        },
      );
      MyPrint.printWarning(response.body);
      Map data = jsonDecode(response.body);
      if (data.containsKey("error")) {
        return data['error']['message'];
      } else {
        currectEPG.clear();
        for (var i in data['epg']) {
          EPG c = EPG();
          c.title = i['title'];
          c.start = i['start'];
          c.end = i['end'];
          c.startdt = DateFormat('hh:mm')
              .format(DateTime.fromMillisecondsSinceEpoch(c.start));
          c.enddt = DateFormat('hh:mm')
              .format(DateTime.fromMillisecondsSinceEpoch(c.end));
          c.description = i['description'];
          currectEPG.add(c);
        }
        return "OK";
      }
    } catch (e) {
      MyPrint.printError(e.toString());
      return e.toString();
    }
  }

  void updateFavorites(var data) {
    favorites.clear();
    for (String i in data['fav']) {
      var k = MyNetwork.channels
          .where(((element) => element.id.toLowerCase().contains(i)))
          .toList();
      if (k.isNotEmpty) {
        favorites.add(k[0]);
      }
      MyPrint.printError(k.length.toString());
    }
    favController.add(favorites.length);
  }

  void changeChannel(int value) async {
    int _k = MyNetwork.currentChanel.pos + value;
    if (_k >= MyNetwork.channels.length) {
      _k = 0;
    }
    if (_k <= 0) {
      _k = MyNetwork.channels.length - 1;
    }
    MyNetwork.currentChanel = MyNetwork.channels[_k];
    MyLocalData.selectedCurrentChannel = MyNetwork.channels[_k].id;
    await storage.write(
        key: "currentChannel", value: MyNetwork.currentChanel.pos.toString());
  }
}

class Channel {
  String id = "";
  int lcn = 1;
  int position = 1;
  String name = "";
  String category = "";
  bool archive = false;
  String icon = "";
  String playBackUrl = "";
  bool isFavorite = false;
  int pos = 0;
}

class Category {
  String id = "";
  String name = "";
  int position = 0;
}

class EPG {
  String id = "";
  String title = "";
  int start = 0;
  int end = 0;
  String description = "";
  String startdt = "";
  String enddt = "";
}

class UserInfos {
  String login = "";
  String expireDate = "";
}

class MyLocalData {
  static int selectedChannelPage = -1;
  static String selectedCurrentChannel = "0";

  static bool isCahnnalPart = false;
}
