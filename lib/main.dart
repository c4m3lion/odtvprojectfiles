// ignore_for_file: prefer_const_constructors
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/pages/login_page.dart';
import 'package:odtvprojectfiles/pages/main_page.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  runApp(Shortcuts(
    shortcuts: <LogicalKeySet, Intent>{
      LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
    },
    child: MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: MyColors.black,
        backgroundColor: MyColors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: MyColors.yellow,
          foregroundColor: MyColors.black,
        ),
        primaryColor: MyColors.yellow,
        focusColor: MyColors.orange,
        highlightColor: MyColors.orange,
        buttonTheme: ButtonThemeData(
          buttonColor: MyColors.yellow, //  <-- dark color
          textTheme:
              ButtonTextTheme.primary, //  <-- this auto selects the right color
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: MyColors.yellow, // Button color
            onPrimary: MyColors.white, // Text color
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/main': (context) => MainPage(),
      },
    ),
  ));
}
