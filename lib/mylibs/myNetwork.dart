import 'dart:convert';

import 'package:http/http.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';

class MyNetwork {
  static String token = "";
  static String userInfo = "";
  static Channel currentChanel = Channel();
  static List<EPG> currectEPG = List.empty(growable: true);
  static List<Channel> channels = List.empty(growable: true);
  static List<Channel> channelsSeach = List.empty(growable: true);
  static List<Channel> favorites = List.empty(growable: true);
  static bool isVideoPlaying = false;

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
        for (var i in data['channels']) {
          Channel c = Channel();
          c.id = i['id'];
          c.lcn = i['lcn'];
          c.position = i['position'];
          c.name = i['name'];
          c.category = i['category'];
          c.archive = i['archive'];
          c.icon = i['icon'];
          channels.add(c);
        }
        currentChanel = channels[0];
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
        for (var i in data['channels']) {
          Channel c = Channel();
          c.id = i['id'];
          c.lcn = i['lcn'];
          c.position = i['position'];
          c.name = i['name'];
          c.category = i['category'];
          c.archive = i['archive'];
          c.icon = i['icon'];
          channels.add(c);
        }
        currentChanel = channels[0];
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
          c.start = i['start'].toString();
          c.end = i['end'].toString();
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
}

class EPG {
  String id = "";
  String title = "";
  String start = "";
  String end = "";
  String description = "";
}
