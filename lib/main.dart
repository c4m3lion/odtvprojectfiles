// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odtvprojectfiles/mylibs/button_detector.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/pages/bettervideo_pagev2.dart';
import 'package:odtvprojectfiles/pages/categorypage.dart';
import 'package:odtvprojectfiles/pages/channellist_page.dart';
import 'package:odtvprojectfiles/pages/favoritelist_page.dart';
import 'package:odtvprojectfiles/pages/languages_page.dart';
import 'package:odtvprojectfiles/pages/loading_page.dart';
import 'package:odtvprojectfiles/pages/login_page.dart';
import 'package:odtvprojectfiles/pages/newPages/newMenu.dart';
import 'package:odtvprojectfiles/pages/newPages/newVideo.dart';
import 'package:odtvprojectfiles/pages/searchpage.dart';
import 'package:odtvprojectfiles/pages/setting_page.dart';
import 'package:odtvprojectfiles/pages/video_page.dart';
import 'package:odtvprojectfiles/pages/videoplayer_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:odtvprojectfiles/translations/codegen_loader.g.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('en'),
        Locale('az'),
        Locale('uk'),
        Locale('ar'),
      ],
      path:
          'assets/translations', // <-- change the path of the translation files
      fallbackLocale: Locale('en'),
      assetLoader: CodegenLoader(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
      },
      child: MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: ThemeData(
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          }),
          focusColor: Colors.cyan.withOpacity(0.5),
          splashColor: Colors.cyan,
          hoverColor: Colors.cyan.withOpacity(0.8),
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              //set border radius more than 50% of height and width to make circle
            ),
          ),
          primaryColor: Colors.orange,
          primarySwatch: Colors.cyan,
          brightness: Brightness.dark,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
          cardTheme: CardTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              //set border radius more than 50% of height and width to make circle
            ),
          ),
          listTileTheme: ListTileThemeData(
              //selectedTileColor: Colors.cyan.withOpacity(0.8),
              ),
          splashFactory: InkRipple.splashFactory,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: MyColors.white,
          backgroundColor: MyColors.white,
          textTheme: TextTheme(),
          appBarTheme: AppBarTheme(
            backgroundColor: MyColors.white,
            foregroundColor: MyColors.black,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                //primary: MyColors.yellow, // Button color
                //onPrimary: MyColors.white, // Text color
                ),
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginPage(),
          '/loading': (context) => LoadingPage(),
          '/main': (context) => MainPage(),
          '/oldvideo': (context) => VideoPage(),
          '/video': (context) => NewVideoPage(),
          '/video2': (context) => VideoPlayerPage(),
          '/button': (context) => ButtonDetector(),
          '/channels': (context) => ChannelListPage(),
          '/favorite': (context) => FavoriteListPage(),
          '/search': (context) => SearchPage(),
          '/settings': (context) => SettingPage(),
          '/category': (context) => CategoryPage(),
          '/language': (context) => LanguagesPage(),
        },
      ),
    );
  }
}
