import 'dart:convert';

import 'package:http/http.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';

class MyNetwork {
  static String token = "";

  Future<String> login({required String login, required String pass}) async {
    try {
      String macAdress = "02:00:00:00:00:00";
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
}
