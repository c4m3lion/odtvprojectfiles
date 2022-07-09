import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:mac_address/mac_address.dart';

import 'package:http/http.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/mylibs/myVideoFunctions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyNetwork {
  FlutterSecureStorage storage = FlutterSecureStorage();
  static String token = "";
  static String userInfo = "";
  static Channel currentChanel = Channel();
  static List<EPG> currectEPG = List.empty(growable: true);
  static List<MyEpgClass> currectPageEPG = List.empty(growable: true);
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
      String macAdress = await readFile();
      if (macAdress == "" || macAdress.isEmpty) {
        macAdress = await initPlatformState();
      }
      MyVideoFunctions.macAdress = macAdress;
      print("macADress: " + macAdress);
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

  Future<String> readFile() async {
    String text = "";
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('/sys/class/net/eth0/address');
      text = await file.readAsString();
    } catch (e) {
      print("Couldn't read file");
    }
    print("AUYEHSAHDHSA: " + text);
    return text;
  }

  Future<String> getChannels() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
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
          String? sharedData = prefs.getString(c.id + "vid");
          if (sharedData == null) {
            c.playBackUrl = await getPlayBack(channel_id: c.id);
            await prefs.setString(c.id + "vid", c.playBackUrl);
          } else {
            c.playBackUrl = sharedData;
          }
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
        final String encodedData = Channel.encode(channels);
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
      Map data = jsonDecode(response.body);
      if (data.containsKey("error")) {
        return data['error']['message'];
      } else {
        currectEPG.clear();
        currectPageEPG.clear();
        List<EPG> tempEpg = List.empty(growable: true);
        var tempTodayTime = "--";
        for (var i in data['epg']) {
          EPG c = EPG();
          c.title = i['title'];
          c.start = i['start'];
          if (currectEPG.length > 0 &&
              currectEPG[currectEPG.length - 1].start == c.start) {
            continue;
          }
          c.end = i['end'];
          c.startDate = DateTime.fromMillisecondsSinceEpoch(c.start);
          c.endDate = DateTime.fromMillisecondsSinceEpoch(c.end);
          c.startdt = DateFormat('HH:mm')
              .format(DateTime.fromMillisecondsSinceEpoch(c.start));
          var tempTime = DateFormat('dd/MM')
              .format(DateTime.fromMillisecondsSinceEpoch(c.start));
          c.enddt = DateFormat('HH:mm')
              .format(DateTime.fromMillisecondsSinceEpoch(c.end));
          c.description = i['description'];
          if (tempTodayTime == "--") {
            tempTodayTime = tempTime;
          }
          if (tempTime != tempTodayTime) {
            currectPageEPG.add(MyEpgClass(tempEpg, tempTodayTime));
            tempTodayTime = tempTime;
            tempEpg.clear();
          }
          tempEpg.add(c);
          currectEPG.add(c);
        }

        if (currectPageEPG.length > 0) {
          currectPageEPG.add(MyEpgClass(tempEpg, tempTodayTime));
          print(currectPageEPG[currectPageEPG.length - 1].date);
          tempEpg.clear();
        }
        return "OK";
      }
    } catch (e) {
      MyPrint.printError(e.toString());
      return e.toString();
    }
  }

  static Future<String> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await GetMac.macAddress;
    } catch (e) {
      platformVersion = '02:00:00:00:00:00';
    }
    return platformVersion;
  }

  void updateFavorites(var data) {
    favorites.clear();
    for (String i in data['fav']) {
      var k = MyNetwork.channels
          .where(((element) => element.id.toLowerCase().contains(i)))
          .toList();
      if (k.isNotEmpty) {
        k[0].isFavorite = true;
        favorites.add(k[0]);
      }
      MyPrint.printError(k.length.toString());
    }
    favController.add(favorites.length);
  }

  void changeChannel(int value) async {
    int _k = MyLocalData.selectedCurrentChannel + value;
    if (_k >= MyNetwork.currentChannels.length) {
      _k = 0;
      MyLocalData.selectedCurrentTag += 1;
      if (MyLocalData.selectedCurrentTag >= MyNetwork.categorys.length) {
        MyLocalData.selectedCurrentTag = 0;
      }

      updateSearchQuery(MyNetwork.categorys[MyLocalData.selectedCurrentTag].id);
    }
    if (_k < 0) {
      _k = MyNetwork.currentChannels.length - 1;
      MyLocalData.selectedCurrentTag -= 1;
      if (MyLocalData.selectedCurrentTag < 0) {
        MyLocalData.selectedCurrentTag = MyNetwork.categorys.length - 1;
      }
      updateSearchQuery(MyNetwork.categorys[MyLocalData.selectedCurrentTag].id);
    }
    MyNetwork.currentChanel = MyNetwork.currentChannels[_k];
    MyLocalData.selectedCurrentChannel = _k;
    await storage.write(
        key: "currentChannel", value: MyNetwork.currentChanel.id.toString());
  }

  void loadChannelById(String id) {
    MyNetwork.currentChanel = MyNetwork.channels.firstWhere(
      (element) => element.id == id,
      orElse: () {
        return MyNetwork.channels[0];
      },
    );
  }
}

void updateSearchQuery(String newQuery) async {
  if (MyNetwork.categorys[MyLocalData.selectedCurrentTag].id == "channel") {
    MyNetwork.currentChannels = MyNetwork.channels;
  } else if (MyNetwork.categorys[MyLocalData.selectedCurrentTag].id ==
      "favorites") {
    MyNetwork().getFavorites();
    MyNetwork.currentChannels = MyNetwork.favorites;
  } else {
    MyNetwork.currentChannels = MyNetwork.channels
        .where(((element) => element.category.contains(newQuery)))
        .toList();
  }
  MyPrint.printWarning(
      MyNetwork.categorys[MyLocalData.selectedCurrentTag].name);
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

  Channel({
    this.id = "",
    this.lcn = 1,
    this.position = 1,
    this.name = "",
    this.category = "",
    this.archive = false,
    this.icon = "",
    this.playBackUrl = "",
    this.isFavorite = false,
    this.pos = 0,
  });

  factory Channel.fromJson(Map<String, dynamic> jsonData) {
    return Channel(
      id: jsonData['id'],
      lcn: jsonData['lcn'],
      position: jsonData["position"],
      name: jsonData['name'],
      category: jsonData['category'],
      archive: jsonData['archive'],
      icon: jsonData['icon'],
      playBackUrl: jsonData['playBackURL'] ?? "",
      isFavorite: jsonData['isFavorite'],
      pos: jsonData['pos'],
    );
  }
  static Map<String, dynamic> toMap(Channel chan) => {
        'id': chan.id,
        'lcn': chan.lcn,
        'position': chan.position,
        'name': chan.name,
        'category': chan.category,
        'archive': chan.archive,
        'icon': chan.icon,
        'playBackUrl': chan.playBackUrl,
        'isFavorite': chan.isFavorite,
        'pos': chan.pos,
      };
  static String encode(List<Channel> chans) => json.encode(
        chans
            .map<Map<String, dynamic>>((music) => Channel.toMap(music))
            .toList(),
      );
  static List<Channel> decode(String chans) =>
      (json.decode(chans) as List<dynamic>)
          .map<Channel>((item) => Channel.fromJson(item))
          .toList();
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
  var startDate = DateTime(1);
  var endDate = DateTime(1);
}

class UserInfos {
  String login = "";
  String expireDate = "";
}

class MyLocalData {
  static int selectedCurrentChannel = -1;
  static int selectedCurrentTag = 0;

  static bool isCahnnalPart = false;
}

class MyEpgClass {
  MyEpgClass(this.epgs, this.date);
  List<EPG> epgs = List.empty(growable: true);
  String date = "11_April";
}
