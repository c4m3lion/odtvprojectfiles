import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odtvprojectfiles/main_old.dart';
import 'package:odtvprojectfiles/mylibs/myDatas.dart';
import 'package:odtvprojectfiles/pages/languages_page.dart';
import 'package:odtvprojectfiles/pages/newPages/newMenu.dart';
import 'package:odtvprojectfiles/screens/TV/VideoPage/tv_video_page.dart';
import 'package:odtvprojectfiles/screens/device_selection_page.dart';
import 'package:odtvprojectfiles/screens/home_page.dart';
import 'package:odtvprojectfiles/screens/login_page.dart';
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
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  bool isTV =
      androidInfo.systemFeatures.contains('android.software.leanback_only');
  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('en'),
        Locale('az'),
        Locale('uk'),
        Locale('ar'),
        Locale('ru'),
      ],
      path:
          'assets/translations', // <-- change the path of the translation files
      fallbackLocale: Locale('en'),
      assetLoader: CodegenLoader(),
      child: isTV ? MyApp() : MyAppAndroid(),
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
            checkboxTheme: CheckboxThemeData(
              fillColor: MaterialStateProperty.all(MyColors.yellow),
            ),
            snackBarTheme: SnackBarThemeData(backgroundColor: MyColors.yellow)),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginPage(),
          '/home': (context) => HomePage(),
          '/language': (context) => LanguagesPage(),
          '/mainhome': (context) => NewMainPage(),
          '/TvVideoPage': (context) => TvVideoPage(),
        },
      ),
    );
  }
}
